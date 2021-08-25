{ pkgs, lib, clang12Stdenv, fetchFromGitHub }:

clang12Stdenv.mkDerivation rec {
  name = "sketchybar";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "7f7539872c2187b4615c777aa4cb4925363faa64";
    sha256 = "00amlnn78vpg3i647km70970jd8rbx34h9gq91acfb2bl60dwgp0";
  };

  buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
    Carbon Cocoa CoreServices IOKit ScriptingBridge SkyLight
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/sketchybar $out/bin/sketchybar
  '';

  meta = with lib; {
    description = "A minimal status bar for macOS";
    inherit (src.meta) homepage;
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}
