{ pkgs, lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v${version}";
    sha256 = "0q97w1pdcc81rfci2sl3x13r5l3vgc7isi15p0bpgzplmjvmlhdj";
  };

  buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
    Carbon Cocoa SkyLight
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/sketchybar $out/bin/sketchybar
  '';

  meta = with lib; {
    description = "A custom macOS statusbar with shell plugin, interaction and graph support";
    inherit (src.meta) homepage;
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}
