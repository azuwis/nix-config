{
  stdenv,
  fetchurl,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ublock-origin";

  version = "1.67.0";

  src = fetchurl {
    url = "https://github.com/gorhill/uBlock/releases/download/${finalAttrs.version}/uBlock0_${finalAttrs.version}.firefox.signed.xpi";
    hash = "sha256-uDxuxJ+Beo0F0oi1PbxwBczsz4LpSQ2Gg7MSCqs8Ezo=";
  };

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p "$out/"
    install -v -m644 "$src" "$out/${finalAttrs.passthru.extid}.xpi"

    runHook postBuild
  '';

  passthru.extid = "uBlock0@raymondhill.net";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=^([0-9.]+)$" ]; };

  meta = {
    changelog = "https://github.com/gorhill/uBlock/releases/tag/${finalAttrs.version}";
    description = "An efficient blocker for Chromium and Firefox";
    homepage = "https://github.com/gorhill/uBlock";
  };
})
