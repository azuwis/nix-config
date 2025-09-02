{
  stdenv,
  fetchurl,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vimfx";

  version = "0.27.5";

  src = fetchurl {
    url = "https://github.com/akhodakivskiy/VimFx/releases/download/v${finalAttrs.version}/VimFx.xpi";
    hash = "sha256-j/vO197mWo0r++4N1KqlHMHnnEn6meuz1Fx94A/L3W4=";
  };

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p "$out/"
    install -v -m644 "$src" "$out/VimFx-unlisted@akhodakivskiy.github.com.xpi"

    runHook postBuild
  '';

  passthru.updateScript = nix-update-script { };
  passthru.extid = "VimFx-unlisted@akhodakivskiy.github.com";

  meta = {
    homepage = "https://github.com/akhodakivskiy/VimFx";
    description = "Vim keyboard shortcuts for Firefox";
  };
})
