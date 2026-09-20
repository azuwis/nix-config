/**
 * Renders an Office document to page images for visual inspection.
 *
 * The office skills call this on the finished file when visual inspection is
 * useful, and pass each returned `imagePath` to `read_image`.
 */

import { spawn } from 'node:child_process'
import { createHash } from 'node:crypto'
import { mkdir, writeFile } from 'node:fs/promises'
import { createRequire } from 'node:module'
import { basename, extname, join } from 'node:path'
import { pathToFileURL } from 'node:url'

export const name = 'render-document'
export const inject = ['tools', 'fs']

const OFFICE_EXTENSIONS = ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx']
const DPI = 120
const MAX_PAGES_PER_CALL = 8

const PAGE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    page: { type: 'integer', required: true, description: '1-based page number.' },
    imagePath: { type: 'string', required: true, description: 'PNG file to pass to read_image.' },
  },
}

const OUTPUT_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  properties: {
    status: {
      type: 'string',
      required: true,
      description: '"ready" with page images, or "skipped" when visual inspection is unavailable.',
    },
    pageCount: {
      type: 'integer',
      required: true,
      description: 'Total pages (slides for a presentation, print pages for a workbook).',
    },
    pages: {
      type: 'array',
      required: true,
      items: PAGE_SCHEMA,
      description: 'Rendered pages. Page 1 when pages is omitted.',
    },
    warnings: {
      type: 'array',
      required: true,
      items: { type: 'string' },
      description: 'Missing fonts, or why visual inspection was skipped.',
    },
  },
}

/**
 * Why page images cannot reach the calling model, or undefined when they can.
 * These are the deployment and route gates `read_image` applies: an attachment
 * store that accepts PNG, and a route that declares image input. Every page
 * this tool renders is a PNG.
 */
async function imageRefusal(ctx, exec) {
  const attachments = ctx.get('attachments')
  if (attachments === undefined) return 'this profile mounts no attachment store'
  if (!attachments.imageLimits.mediaTypes.includes('image/png')) return 'this deployment does not accept PNG images'
  const routed = exec.agent?.session?.requestHeader()?.config
  const provider = routed?.provider ?? exec.agent?.options.provider
  const model = routed?.model ?? exec.agent?.options.model
  const llm = ctx.get('llm')
  if (provider === undefined || model === undefined || llm === undefined) return 'the current model route could not be resolved'
  const info = await llm.resolveModelInfo(provider, model, exec.signal)
  if (!info.inputModalities?.includes('image')) return `model "${model}" does not declare image input`
  return undefined
}

/** The `skipped` outcome for a reason string or an Error. An Error contributes its message. */
function skipped(reason) {
  const text = reason instanceof Error ? reason.message : reason
  return { status: 'skipped', pageCount: 0, pages: [], warnings: [`visual inspection skipped: ${text}`] }
}

/** Run a poppler tool with the PDF on stdin and return its stdout. */
function runPoppler(binary, args, pdf, signal) {
  return new Promise((resolve, reject) => {
    const child = spawn(binary, args, { signal })
    const stdout = []
    const stderr = []
    child.stdout.on('data', (chunk) => stdout.push(chunk))
    child.stderr.on('data', (chunk) => stderr.push(chunk))
    // Only a spawn that cannot find its binary means poppler is missing.
    child.on('error', (error) => {
      reject(error?.code === 'ENOENT' && error.syscall?.startsWith('spawn')
        ? new Error(`poppler is not available (${error.path})`)
        : error)
    })
    child.on('close', (code) => {
      if (code === 0) resolve(Buffer.concat(stdout))
      else reject(new Error(`${binary} exited with ${code}: ${Buffer.concat(stderr).toString('utf8').trim()}`))
    })
    child.stdin.on('error', () => {})
    child.stdin.end(pdf)
  })
}

/** Total page count reported by poppler. */
async function readPageCount(pdf, signal) {
  const text = (await runPoppler('pdfinfo', ['-'], pdf, signal)).toString('utf8')
  const match = /^Pages:\s+(\d+)$/m.exec(text)
  if (match === null) throw new Error('pdfinfo reported no page count')
  return Number(match[1])
}

/** Cache directory name for one source file, built from a readable stem and a path hash. */
function pageName(sourcePath) {
  const stem = basename(sourcePath, extname(sourcePath)).replace(/[^\w.-]+/g, '_')
  return `${stem}-${createHash('sha256').update(sourcePath).digest('hex').slice(0, 8)}`
}

export async function apply(ctx) {
  // A store plugin has no node_modules of its own, and the profile fallback
  // under $DSH_HOME/profiles is out of reach, so resolve from the installation.
  const fromInstallation = createRequire(ctx.profileContext.installAnchor)
  const load = (specifier) => import(pathToFileURL(fromInstallation.resolve(specifier)).href)
  const { defineTool } = await load('@deepseek-ai/dsh-tools')
  const { dshCachePath } = await load('@deepseek-ai/dsh-home-paths')

  ctx.tools.register(defineTool({
    name: 'render_document',
    description:
      'Render a Word, PowerPoint, or Excel file to page images for visual inspection. '
      + 'Omit pages to prepare page 1 and learn pageCount, then request the remaining pages in small batches. '
      + 'Pass each returned imagePath to read_image. '
      + 'When status is "skipped", complete the structural and content checks and state that visual layout was not inspected.',
    parameters: {
      file_path: {
        type: 'string',
        required: true,
        description: 'Office file to render, resolved by the filesystem backend.',
      },
      pages: {
        type: 'array',
        items: { type: 'integer' },
        description: `1-based pages to render, at most ${MAX_PAGES_PER_CALL} per call. `
          + 'Defaults to page 1. Pages outside 1..pageCount are ignored, and a request with no page in range fails.',
      },
    },
    output: {
      schema: OUTPUT_SCHEMA,
      render: (_args, value) => [{ type: 'text', text: JSON.stringify(value, undefined, 2) }],
    },
    async execute(args, exec) {
      const fs = ctx.fs
      const target = await fs.resolve(args.file_path, { signal: exec.signal })
      const info = await fs.stat(target, exec.signal)
      if (info?.type !== 'file') throw new Error(`render_document: "${args.file_path}" is not a file`)
      const sourcePath = fs.processPath(target)
      const extension = extname(sourcePath).slice(1).toLowerCase()
      if (!OFFICE_EXTENSIONS.includes(extension)) {
        throw new Error(`render_document: "${args.file_path}" must end in ${OFFICE_EXTENSIONS.join(', ')}`)
      }

      const refusal = await imageRefusal(ctx, exec)
      if (refusal !== undefined) return skipped(refusal)
      const officeToPdf = ctx.get('officeToPdf')
      if (officeToPdf === undefined) return skipped('this profile mounts no Office converter')

      let converted
      try {
        converted = await officeToPdf.convert({
          extension,
          priority: 'foreground',
          source: {
            key: sourcePath,
            version: info.version,
            ...(info.size === undefined ? {} : { bytes: info.size }),
            // `officeToPdf` rejects a read version that differs from the
            // requested one, so report the version seen after the read.
            read: async (signal, maxBytes) => {
              const bytes = await fs.readBytes(target, signal, maxBytes)
              const after = await fs.stat(target, signal)
              if (after?.type !== 'file') throw new Error('the source changed during conversion')
              return { bytes, version: after.version }
            },
          },
        }, exec.signal)
      } catch (error) {
        return skipped(error)
      }

      const warnings = converted.missingFonts.map((family) => `missing font: ${family}`)
      let pageCount
      try {
        pageCount = await readPageCount(converted.pdf, exec.signal)
      } catch (error) {
        return skipped(error)
      }

      const requested = [...new Set(args.pages ?? [1])]
      const present = requested.filter((page) => page >= 1 && page <= pageCount)
      if (present.length === 0) {
        // Fail the call when the caller asks for pages the document does not
        // have, so the model retries with a valid page.
        throw new Error(`render_document: no requested page exists in a ${pageCount}-page document`)
      }
      if (present.length < requested.length) {
        warnings.push(`ignored ${requested.length - present.length} requested page number(s) outside 1-${pageCount}`)
      }
      const selected = present.slice(0, MAX_PAGES_PER_CALL)
      if (selected.length < present.length) {
        warnings.push(`rendering ${selected.length} of ${present.length} requested pages this call. Request the rest in another call.`)
      }

      const directory = dshCachePath('render-document', pageName(sourcePath))
      try {
        await mkdir(directory, { recursive: true })
        const pages = []
        for (const page of selected) {
          const imagePath = join(directory, `page-${page}.png`)
          const png = await runPoppler('pdftoppm', [
            '-png', '-singlefile', '-r', String(DPI),
            '-f', String(page), '-l', String(page), '-',
          ], converted.pdf, exec.signal)
          await writeFile(imagePath, png)
          pages.push({ page, imagePath })
        }
        return { status: 'ready', pageCount, pages, warnings }
      } catch (error) {
        return skipped(error)
      }
    },
  }))
}
