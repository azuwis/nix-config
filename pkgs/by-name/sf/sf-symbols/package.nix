{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  xar,
  cpio,
  fonts ? true,
  full ? false,
  app ? false,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sf-symbols";
  version = "5.1";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Symbols-${finalAttrs.version}.dmg";
    hash = "sha256-7HIOlAYpQHzyoMhW2Jtwq2Tor8ojs4mTHjUjfMKKMM4=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    undmg
    xar
    cpio
  ];

  installPhase = ''
    xar -xf SF\ Symbols.pkg -s SFSymbols.pkg/Payload
    cat SFSymbols.pkg/Payload | gzip -d | cpio -i
  ''
  + lib.optionalString fonts ''
    mkdir -p $out/share/fonts/truetype
    cp ./Library/Fonts/${if full then "*" else "SF-Pro.ttf"} $out/share/fonts/truetype
  ''
  + lib.optionalString app ''
    mkdir -p $out/Applications
    cp -R ./Applications/SF\ Symbols.app $out/Applications
  '';

  meta = {
    description =
      if app then
        "Tool that provides consistent, highly configurable symbols for apps"
      else
        "Fonts from SF Symbols";
    homepage = "https://developer.apple.com/sf-symbols/";
    platforms = if app then lib.platforms.darwin else lib.platforms.all;
  };
})
