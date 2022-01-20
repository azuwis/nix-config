{ lib, stdenv, darwin, fetchFromGitHub }:

let
  target = {
    "aarch64-darwin" = "arm";
    "x86_64-darwin" = "x86";
  }.${stdenv.hostPlatform.system};
in

stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v${version}";
    sha256 = "sha256-rgKlDV2P9XIuQCVJYVZLm+HF+th/31gBbJdqtryf40M=";
  };

  buildInputs = with darwin.apple_sdk.frameworks; [
    Carbon Cocoa SkyLight
  ];

  buildPhase = ''
    make ${target}
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/sketchybar_${target} $out/bin/sketchybar
  '';

  meta = with lib; {
    description = "A highly customizable macOS status bar replacement";
    inherit (src.meta) homepage;
    platforms = platforms.darwin;
    license = licenses.gpl3;
  };
}
