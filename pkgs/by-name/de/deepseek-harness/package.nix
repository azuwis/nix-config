{
  lib,
  stdenv,
  fetchFromGitHub,
  bashInteractive,
  curl,
  fetchPnpmDeps,
  makeBinaryWrapper,
  node-gyp,
  nodejs_24,
  pnpmBuildHook,
  pnpmConfigHook,
  pnpm_11,
  python3,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

let
  nodejs = nodejs_24;
  pnpm = pnpm_11;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "deepseek-harness";
  version = "0.1.1-rc.1";

  src = fetchFromGitHub {
    owner = "deepseek-ai";
    repo = "deepseek-harness";
    rev = "528c682e061696f5a160f363f236ecbf53cbd006";
    hash = "sha256-daCh+O/lbv5QrJvslyEHfy+p9HcYhgTzda6I1VNnJZk=";
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
    node-gyp
    python3
    makeBinaryWrapper
  ];

  # pnpmConfigHook installs with lifecycle scripts disabled. node-pty ships
  # no Linux prebuild and upstream allowBuilds lists it, so rebuild it to get
  # a compiled pty.node (node-gyp uses the headers from the nixpkgs nodejs).
  preBuild = ''
    # scripts/build.ts embeds the commit hash in the client build record and
    # falls back to git, which is not available in the sandbox. This is
    # upstream's escape hatch for non-Git build environments. The src tracks
    # the default branch by commit, so derive the value instead of pinning it.
    export DSH_CLIENT_COMMIT_HASH=${finalAttrs.src.rev}

    pnpm rebuild node-pty
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/dsh
    cp -r . $out/libexec/dsh/

    # The whole tree is shipped because the CLI resolves workspace packages
    # in-tree at runtime (linkWorkspacePackages: true in pnpm-workspace.yaml):
    # the loader imports plugins by bare specifier and dsh-web-app locates the
    # frontend dist via require.resolve('@deepseek-ai/dsh-web-frontend/dist/index.html').
    # Dev/test/doc files come along for the ride.

    # Optional packages for other platforms leave dangling symlinks in the
    # virtual store; drop them so the fixup phase passes.
    find $out/libexec/dsh/node_modules/.pnpm -type l ! -exec test -e {} \; -delete

    # pnpm only links workspace packages into each dependent package's own
    # node_modules, so the loader's bare import() of workspace specifiers does
    # not resolve from its own directory. Mirror the virtual store's scoped
    # links into the root node_modules so bare specifiers resolve anywhere in
    # the tree.
    shopt -s nullglob
    store_scopes=("$out/libexec/dsh/node_modules/.pnpm/node_modules/"@*/)
    for scope in "''${store_scopes[@]}"; do
      scope_name=$(basename "$scope")
      mkdir -p "$out/libexec/dsh/node_modules/$scope_name"
      for pkg in "$scope"*; do
        # -n: do not dereference an existing symlink-to-dir when replacing it.
        ln -sfn "../.pnpm/node_modules/$scope_name/$(basename "$pkg")" \
          "$out/libexec/dsh/node_modules/$scope_name/$(basename "$pkg")"
      done
    done

    # --expose-internals is required by the HMR service (vendor/hmr throws
    # without it) and preferred by the loader's internal module access. It is
    # disallowed in NODE_OPTIONS, so it must precede the script path to land in
    # process.execArgv.
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

  nativeInstallCheckInputs = [
    curl
    writableTmpDirAsHomeHook
  ];

  installCheckPhase = ''
    set -e

    $out/bin/dsh --version

    # Smoke the native modules that pnpmConfigHook skipped: a missing pty.node
    # would only surface when a terminal session starts, so exercise it here.
    (
      cd $out/libexec/dsh/packages/subprocess/subprocess-local
      SHELL_PATH="${stdenv.shell}" ${nodejs}/bin/node -e '
        const pty = require("node-pty");
        const child = pty.spawn(process.env.SHELL_PATH, ["-c", "printf pty-ok"], {});
        let out = "";
        child.onData((d) => (out += d));
        child.onExit(({ exitCode }) => {
          if (exitCode !== 0 || !out.includes("pty-ok")) process.exit(1);
        });
      '
    )

    # Boot the web profile and verify it serves HTML. Guards the loader's bare
    # import() of workspace specifiers, the require.resolve() of the built
    # frontend dist, and the --expose-internals requirement.
    $out/bin/dsh --profile web >server.log 2>&1 &
    pid=$!
    trap 'kill $pid 2>/dev/null || true' EXIT

    for i in $(seq 1 60); do
      if curl -fsS http://127.0.0.1:3080/ >page.html 2>/dev/null \
        && grep -q '<!doctype html>' page.html; then
        exit 0
      fi
      sleep 1
    done

    echo "dsh web profile failed to serve http://127.0.0.1:3080/" >&2
    cat server.log >&2
    exit 1
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    hash = "sha256-+PsdK9u3ZKv4XtSc8tBKKP48J/95/CGTMIUf8Q8dbok=";
    fetcherVersion = 4;
    # The lockfile pulls in large tarballs (rolldown bindings, @openai/codex)
    # for every platform; pnpm's default 60s fetch timeout is not enough on
    # slow connections.
    prePnpmInstall = ''
      pnpm config set fetch-timeout 600000
      pnpm config set fetch-retries 5
    '';
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      # Track the default branch HEAD, but keep the version at the plain
      # release number (strip the dsh-v prefix and -unstable-<date> suffix).
      "--version=branch"
      "--version-regex=dsh-v(.*)-unstable-.*"
    ];
  };

  meta = {
    description = "AI agent harness with a plugin-based architecture";
    longDescription = ''
      DeepSeek Harness (dsh) is a self-hosted AI agent harness built around a
      plugin architecture - "Everything is a Plugin". It ships a CLI and a web
      UI and is extended through workspace plugins.
    '';
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
    maintainers = [ ];
    mainProgram = "dsh";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
