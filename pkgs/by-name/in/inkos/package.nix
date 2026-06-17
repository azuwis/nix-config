{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_10,
  nodejs-slim_22,
  makeBinaryWrapper,
  versionCheckHook,
  nix-update-script,
}:

let
  pnpm = pnpm_10;
  nodejs = nodejs-slim_22;
  pnpm' = pnpm.override { inherit nodejs; };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "inkos";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Narcooo";
    repo = "inkos";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1ESVyjbOPrKtjCbKz+5CoXa9+KkMyooZw3xWPq6AtHU=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-B0Q9G6dz9+yzIT0Lmht/ODP2SBnjskgtPN5/Ao4nqNs=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    nodejs
    pnpm'
    pnpmConfigHook
  ];

  # The studio package build script uses npm.
  # nodejs-slim doesn't include npm - redirect npm to pnpm.
  buildPhase = ''
    runHook preBuild

    npm() { pnpm "$@"; }
    export -f npm

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    dest=$out/lib/node_modules/inkos
    mkdir -p $dest

    cp -r packages/cli/dist $dest/
    cp packages/cli/package.json $dest/

    rm -rf node_modules
    pnpm config set nodeLinker hoisted
    pnpm install --offline --prod --ignore-scripts --frozen-lockfile

    # Copy production npm deps (hoisted: real dirs, no symlinks).
    cp -r node_modules "$dest/"

    # pnpm --prod with nodeLinker=hoisted does not link workspace
    # packages (workspace:* protocol) into node_modules.
    # https://github.com/pnpm/pnpm/issues/7553
    mkdir -p "$dest/node_modules/@actalk/inkos-core"
    cp -r packages/core/dist "$dest/node_modules/@actalk/inkos-core/"
    cp -r packages/core/genres "$dest/node_modules/@actalk/inkos-core/"
    cp packages/core/package.json "$dest/node_modules/@actalk/inkos-core/"

    mkdir -p "$dest/node_modules/@actalk/inkos-studio"
    cp -r packages/studio/dist "$dest/node_modules/@actalk/inkos-studio/"
    cp packages/studio/package.json "$dest/node_modules/@actalk/inkos-studio/"

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/inkos \
      --add-flags "$dest/dist/index.js"

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Story Creation AI Agent for novel, scripts, interactive games, and IP content";
    homepage = "https://github.com/Narcooo/inkos";
    license = lib.licenses.agpl3Only;
    mainProgram = "inkos";
    platforms = lib.platforms.unix;
  };
})
