{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  curl,
  fetchPnpmDeps,
  makeBinaryWrapper,
  nodejs_24,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_11,
  python3,
  runCommand,
  testers,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

let
  nodejs = nodejs_24;
  pnpm = pnpm_11;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "deepseek-harness";
  version = "0.1.5-alpha.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "deepseek-ai";
    repo = "deepseek-harness";
    tag = "dsh-v${finalAttrs.version}";
    hash = "sha256-xkz9l3r9pYV+45Sdkh48rh9tpO+0HZnmjrD2stZXCwk=";
    postCheckout = "git -C $out rev-parse HEAD > $out/.gitrev";
  };

  postPatch = ''
    substituteInPlace packages/terminal/terminal-bash/src/config.ts \
      --replace-fail \
        "export const DEFAULT_BASH_SHELL = '/bin/bash'" \
        "export const DEFAULT_BASH_SHELL = '${lib.getExe bashInteractive}'"
  '';

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    pnpmBuildHook
    makeBinaryWrapper
    python3
  ];

  preBuild = ''
    export DSH_CLIENT_COMMIT_HASH="$(< .gitrev)"
    rm .gitrev

    # node-gyp needs the nixpkgs Node headers.
    export npm_config_nodedir=${nodejs}

    # pnpmConfigHook installs with --ignore-scripts, so build node-pty here.
    # build_from_source drops the shipped prebuilds, so node-gyp compiles it.
    (
      export npm_config_build_from_source=true
      cd node_modules/.pnpm/node_modules/node-pty
      pnpm run install
      pnpm run postinstall
    )
  '';

  # The whole repo tree is the runtime. Packages import each other by name,
  # resolved through the node_modules links pnpm created, and plugin names in
  # config files resolve from ~/.dsh/profiles/node_modules, which dsh fills
  # automatically on startup. So copy everything, don't prune. Docs and
  # tests ride along, which is fine.
  installPhase = ''
    runHook preInstall

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

  pnpmBuildScript = "build:official";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    hash = "sha256-V5B91UbucTDKHw1i54pKm58VHm/iNBmCiDUAH35c9CA=";
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
