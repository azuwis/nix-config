{ pkgs, lib, clang12Stdenv, fetchFromGitHub }:

clang12Stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "2021-09-07";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "fbe7000691a62ab177c4012826018e157ed04059";
    sha256 = "07b4dkp1l4fdqckiz2y7hnv02l4f3drifksn8lxgwlm056mqwr8b";
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
