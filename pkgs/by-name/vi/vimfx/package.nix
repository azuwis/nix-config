{
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "vimfx";
  version = "0.28.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchurl {
    url = "https://github.com/akhodakivskiy/VimFx/releases/download/v${finalAttrs.version}/VimFx.xpi";
    hash = "sha256-zHT6ND5TjVDzKVk4j/sGrsYgQyZcoCz2lR+9stexQGQ=";
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
