{ lib, stdenvNoCC, fetchurl, undmg, xar, cpio
, fonts ? true
, full ? false
, app ? false
}:

stdenvNoCC.mkDerivation rec {
  pname = "sf-symbols";
  version = "2.1";

  src = fetchurl {
    url = "https://devimages-cdn.apple.com/design/resources/download/SF-Symbols-${version}.dmg";
    sha256 = "0bn00f1jm48xwl11f0hnmasdl7p6pnwsljgn5krggpbhw3g5dbwp";
  };

  sourceRoot = ".";
  buildInputs = [ undmg xar cpio ];
  installPhase = ''
    xar -Oxf SF\ Symbols.pkg SFSymbols.pkg/Payload | gzip -d | cpio -i
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
    description = if app then "Tool that provides consistent, highly configurable symbols for apps" else "Fonts from SF Symbols";
    homepage = "https://developer.apple.com/sf-symbols/";
    platforms = if app then lib.platforms.darwin else lib.platforms.all;
  };
}
