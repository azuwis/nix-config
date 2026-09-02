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
  testers,
  runCommand,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

let
  nodejs = nodejs_24;
  pnpm = pnpm_11;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "deepseek-harness";
  version = "0.1.2-alpha.3";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "deepseek-ai";
    repo = "deepseek-harness";
    tag = "dsh-v${finalAttrs.version}";
    hash = "sha256-2kEfAkror7msg7sSgYKO3OuWEWGSZsYRA1juNrbopCA=";
    postCheckout = "git -C $out rev-parse HEAD > $out/.gitrev";
  };

  # The built-in web fetch resolves DNS itself and pins the connection, which
  # breaks on proxy-only networks. The patch uses global fetch instead when
  # NODE_USE_ENV_PROXY=1, and leaves the pinned transport alone otherwise.
  patches = [ ./web-fetch-proxy.patch ];

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
  ];

  preBuild = ''
    export DSH_CLIENT_COMMIT_HASH="$(< .gitrev)"
    rm .gitrev

    # Matches official release branding
    export DSH_CLIENT_TITLE="DeepSeek Harness"
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
    makeBinaryWrapper ${nodejs}/bin/node $out/bin/dsh \
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

  # Smoke the native modules that pnpmConfigHook skipped: a missing pty.node
  # would only surface when a terminal session starts, so exercise it here.
  installCheckPhase = ''
    cd $out/libexec/dsh/packages/subprocess/subprocess-local
    SHELL_PATH="${stdenv.shell}" ${nodejs}/bin/node -e '
      const pty = require("node-pty");
      let out = "";
      const p = pty.spawn(process.env.SHELL_PATH, ["-c", "printf pty-ok"], {});
      p.onData((d) => (out += d));
      p.onExit(({ exitCode }) => process.exit(exitCode !== 0 || !out.includes("pty-ok") ? 1 : 0));
    '
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    hash = "sha256-KK34f9oTm/ofvAR9VV/FGnR1jJAQUyFzQMz7a/Xv6VE=";
    fetcherVersion = 4;
    # The lockfile pulls in large tarballs (rolldown bindings, @openai/codex)
    # for every platform. pnpm's default 60s fetch timeout is not enough on
    # slow connections.
    prePnpmInstall = ''
      pnpm config set fetch-timeout 600000
      pnpm config set fetch-retries 5
    '';
  };

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version=unstable"
        "--version-regex=dsh-v(.*)"
      ];
    };

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
            __darwinAllowLocalNetworking = true;
            # chokidar's native fs.watch fails with "EMFILE: too many open files"
            # in the darwin sandbox, use stat polling there.
            env.CHOKIDAR_USEPOLLING = lib.optionalString stdenv.hostPlatform.isDarwin "true";
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
  };
})
