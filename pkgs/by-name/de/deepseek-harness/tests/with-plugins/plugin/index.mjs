import { defineTool } from '@deepseek-ai/dsh-tools'

export const name = 'dsh-test-plugin'

export function apply() {
  process.stderr.write('test plugin loaded with ' + typeof defineTool + '\n')
}
