{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  curl,
  fetchPnpmDeps,
  makeBinaryWrapper,
  nodejs-slim_24,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_11,
  python3,
  ripgrep,
  runCommand,
  testers,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

let
  nodejs = nodejs-slim_24;
  pnpm = pnpm_11;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "deepseek-harness";
  version = "0.1.5-rc.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "deepseek-ai";
    repo = "deepseek-harness";
    tag = "dsh-v${finalAttrs.version}";
    hash = "sha256-0fqzN43mDlUvp/fuOERC5ib4aaTbnfC2MiKxsc6aB14=";
    postCheckout = "git -C $out rev-parse HEAD > $out/.gitrev";
  };

  postPatch = ''
    # Optional codex/claude-code subagents, still installable with
    # `dsh plugin add`. Dropping them keeps their CLI binaries out of the build.
    # See also `pnpmWorkspaces` in pnpmDeps.
    rm -r packages/subagent/subagent-claude-code packages/subagent/subagent-codex
    substituteInPlace tsconfig.host.json \
      --replace-fail "    { \"path\": \"./packages/subagent/subagent-claude-code\" }," "" \
      --replace-fail "    { \"path\": \"./packages/subagent/subagent-codex\" }," ""

    substituteInPlace packages/terminal/terminal-bash/src/config.ts \
      --replace-fail \
        "export const DEFAULT_BASH_SHELL = '/bin/bash'" \
        "export const DEFAULT_BASH_SHELL = '${lib.getExe bashInteractive}'"

    # Use nixpkgs' rg instead of the binary @vscode/ripgrep ships.
    substituteInPlace packages/fs/tool-fs-search/src/search-core.ts \
      --replace-fail \
        "return (await import('@vscode/ripgrep')).rgPath" \
        "return '${lib.getExe ripgrep}'"
  '';

  nativeBuildInputs = [
    nodejs.out # Plain nodejs would also pull in the unneeded .dev output
    pnpm
    pnpmConfigHook
    pnpmBuildHook
    makeBinaryWrapper
    python3
  ];

  preBuild = ''
    export DSH_CLIENT_COMMIT_HASH="$(< .gitrev)"
    rm .gitrev
  '';

  # The whole repo tree is the runtime: packages import each other by name
  # through the node_modules links, and plugin names in config files resolve
  # from ~/.dsh/profiles/node_modules, which dsh fills on startup.
  installPhase = ''
    runHook preInstall

    # test-support is a leaf and drags vitest, vite and esbuild in with it.
    rm -r packages/test-support

    # Replace pnpmConfigHook's dev+prod strict node_modules with the
    # production-only flat one the shipped tree needs: --prod drops the
    # dev dependencies, hoisting keeps peer dependencies resolvable.
    # The reinstall also discards pnpmConfigHook's patched shebangs, which is
    # fine because nothing runs node_modules/.bin.
    find . -name node_modules -type d -prune -exec rm -r {} +
    pnpm install --prod --offline --ignore-scripts --frozen-lockfile --shamefully-hoist

    # pnpm's bundled node-gyp needs the nixpkgs Node headers.
    export npm_config_nodedir=${nodejs}

    # pnpm rebuild does nothing unless the dependent project is named; the test
    # below fails if the addon is missing. build_from_source drops the prebuilds.
    npm_config_build_from_source=true pnpm --filter @deepseek-ai/dsh-subprocess-local rebuild node-pty
    test -f node_modules/.pnpm/node-pty@*/node_modules/node-pty/build/Release/pty.node

    # node-gyp left the Python path in config.gypi. Dropping it keeps python3
    # out of the closure, which disallowedReferences enforces.
    rm node_modules/node-pty/build/config.gypi

    # Already replaced by nixpkgs' ripgrep in postPatch.
    rm -r node_modules/.pnpm/@vscode+ripgrep*

    # vendor/loader only falls back to it without --expose-internals, which the
    # wrapper always passes.
    rm -r node_modules/.pnpm/node-addon-require-builtin*

    # koffi's loader prefers the glibc build, so its musl copy is unused here.
    find node_modules/.pnpm -path '*@koromix/koffi-*/musl_*' -delete

    # Prune the links any package removal leaves dangling.
    find . -xtype l -delete

    mkdir -p $out/libexec/dsh
    cp -r . $out/libexec/dsh/

    # --expose-internals must sit before the script path: NODE_OPTIONS
    # forbids it, and the hot-reload (HMR) service requires it.
    makeBinaryWrapper ${lib.getExe nodejs} $out/bin/dsh \
      --add-flags "--expose-internals $out/libexec/dsh/apps/cli/lib/bin.js" \
      --prefix PATH : ${
        lib.makeBinPath [
          bashInteractive
          pnpm
        ]
      }

    runHook postInstall
  '';

  doInstallCheck = true;

  # Smoke the native addons the build never loads: a missing pty.node breaks
  # startup, a missing system.node breaks the first session write lease.
  installCheckPhase = ''
    (
      cd $out/libexec/dsh/packages/subprocess/subprocess-local
      SHELL_PATH="${stdenv.shell}" ${lib.getExe nodejs} --input-type=module -e '
        import pty from "node-pty";
        let out = "";
        const p = pty.spawn(process.env.SHELL_PATH, ["-c", "printf pty-ok"], {});
        p.onData((d) => (out += d));
        p.onExit(({ exitCode }) => {
          if (exitCode === 0 && out.includes("pty-ok")) return;
          console.error("pty check failed: exit " + exitCode + ", output " + JSON.stringify(out));
          process.exit(1);
        });
      '
    )

    # Import the way session-persistence-jsonl does, which also tests
    # platform-package resolution. A second lock on the same file must fail.
    (
      cd $out/libexec/dsh/packages/session/session-persistence-jsonl
      ${lib.getExe nodejs} --input-type=module -e '
        import { openSync } from "node:fs";
        import { tryLockExclusive } from "@deepseek-ai/node-addon-system/flock";
        const path = process.env.TMPDIR + "/dsh-flock-check";
        await tryLockExclusive(openSync(path, "w"));
        try {
          await tryLockExclusive(openSync(path, "w"));
          throw new Error("contender acquired the lock");
        } catch (error) {
          if (error.code !== "EAGAIN" && error.code !== "EWOULDBLOCK") throw error;
        }
      '
    )
  '';

  # The shipped tree runs no Python, so a surviving reference fails the build.
  disallowedReferences = [ python3 ];

  pnpmBuildScript = "build:official";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    hash = "sha256-DiZ3PEn8oxj+GOP/WPtzbVB23ee/q0o+3yDNZhUnmAo=";
    fetcherVersion = 4;
    # Fetch only the platforms in meta.platforms. `--force=false` is required
    # because fetchPnpmDeps passes `--force`, which would otherwise pull every
    # platform in the lockfile.
    pnpmInstallFlags = [
      "--force=false"
      "--os=linux"
      "--os=darwin"
      "--cpu=x64"
      "--cpu=arm64"
      "--libc=glibc"
    ];
    # `!` excludes these optional subagents, so their CLI binaries never reach
    # the store. The main derivation's postPatch drops them from the built tree.
    pnpmWorkspaces = [
      "!@deepseek-ai/dsh-subagent-claude-code"
      "!@deepseek-ai/dsh-subagent-codex"
    ];
  };

  passthru = {
    tests = {
      version = testers.testVersion { package = finalAttrs.finalPackage; };

      # Boots the web profile and checks it serves a page. Catches the two
      # fragile pieces: the loader's bare import() of workspace packages, and
      # the --expose-internals flag.
      web-boot =
        runCommand "deepseek-harness-web-boot"
          {
            nativeBuildInputs = [
              curl
              writableTmpDirAsHomeHook
            ];
            # chokidar's native fs.watch fails with "EMFILE: too many open files"
            # in the darwin sandbox, use stat polling there.
            env.CHOKIDAR_USEPOLLING = lib.optionalString stdenv.hostPlatform.isDarwin "true";
            __darwinAllowLocalNetworking = true;
          }
          ''
            cd "$HOME"
            ${lib.getExe finalAttrs.finalPackage} --profile web --no-open --port 0 >server.log 2>&1 &
            pid=$!
            trap 'kill $pid 2>/dev/null || true' EXIT

            # The web profile requires the ?token= from the launch URL (401
            # without it). -c turns on cookie handling for the token redirect.
            # --port 0 avoids clashing with anything already on 3080.
            for i in {1..60}; do
              url=$(sed -n 's#.*dsh web: \(http://[^[:space:]]*\).*#\1#p' server.log | head -1)
              if [ -n "$url" ]; then
                if curl --noproxy '*' -fsSL -c cookies.txt "$url" >page.html 2>/dev/null \
                  && grep -q '<!doctype html>' page.html; then
                  touch $out
                  exit 0
                fi
              fi
              sleep 1
            done

            echo "dsh web profile failed to serve ''${url:-its web UI}" >&2
            cat server.log >&2
            exit 1
          '';
    };
    updateScript = nix-update-script {
      extraArgs = [
        "--version=unstable"
        "--version-regex=dsh-v(.*)"
      ];
    };
  };

  meta = {
    description = "Open-source agent harness developed by DeepSeek AI";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    # Dependency closure ships prebuilt native modules (node-pty, @vscode/ripgrep, ...).
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    maintainers = [ ];
    mainProgram = "dsh";
    # Upstream's native-addon support matrix, mirrored by the `fetchPnpmDeps` flags above:
    # https://github.com/deepseek-ai/deepseek-harness/blob/master/native/system/docs/support-matrix.md
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
})
