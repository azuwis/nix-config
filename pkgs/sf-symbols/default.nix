{ lib, stdenvNoCC, fetchurl, undmg, xar, cpio }:

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
    xar -Oxf SF\ Symbols.pkg SFSymbols.pkg/Payload | gzip -d | cpio -id ./Library/Fonts/SF-Pro.ttf
    mkdir -p $out/share/fonts/truetype
    cp ./Library/Fonts/SF-Pro.ttf $out/share/fonts/truetype
  '';

  meta = {
    description = "Tool that provides consistent, highly configurable symbols for apps";
    homepage = "https://developer.apple.com/sf-symbols/";
    platforms = lib.platforms.all;
  };
}
