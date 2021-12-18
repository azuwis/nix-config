{ pkgs, lib, stdenv, fetchFromGitHub }:

let
  target = {
    "aarch64-darwin" = "arm";
    "x86_64-darwin" = "x86";
  }.${stdenv.hostPlatform.system};
in

stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v${version}";
    sha256 = "sha256-5psncEuSxBPDp5OM3Y8mF4bTwn1z1Y0ilwev5iq9FMI=";
  };

  buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
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
    description = "A custom macOS statusbar with shell plugin, interaction and graph support";
    inherit (src.meta) homepage;
    platforms = platforms.darwin;
    license = licenses.gpl3;
  };
}
