{
  stdenv,
  fetchurl,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ublock-origin";

  version = "1.65.1b8";

  src = fetchurl {
    url = "https://github.com/gorhill/uBlock/releases/download/${finalAttrs.version}/uBlock0_${finalAttrs.version}.firefox.signed.xpi";
    hash = "sha256-GftZH4USfvEmkUUBgy1Tzv4l0MCNWBi023Jb68v/WIU=";
  };

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p "$out/"
    install -v -m644 "$src" "$out/${finalAttrs.passthru.extid}.xpi"

    runHook postBuild
  '';

  passthru.extid = "uBlock0@raymondhill.net";
  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/gorhill/uBlock/releases/tag/${finalAttrs.version}";
    description = "An efficient blocker for Chromium and Firefox";
    homepage = "https://github.com/gorhill/uBlock";
  };
})
