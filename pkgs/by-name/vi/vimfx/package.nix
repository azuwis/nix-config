{
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vimfx";
  version = "0.27.7";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchurl {
    url = "https://github.com/akhodakivskiy/VimFx/releases/download/v${finalAttrs.version}/VimFx.xpi";
    hash = "sha256-M5JXApqSv87AvWUfzyPj47Mi2HI/b0noJl/kAmzRY6I=";
  };

  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p "$out/"
    install -v -m644 "$src" "$out/VimFx-unlisted@akhodakivskiy.github.com.xpi"

    runHook postBuild
  '';

  passthru.extid = "VimFx-unlisted@akhodakivskiy.github.com";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Vim keyboard shortcuts for Firefox";
    homepage = "https://github.com/akhodakivskiy/VimFx";
  };
})
