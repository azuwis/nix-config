{ pkgs, lib, clang12Stdenv, fetchFromGitHub }:

clang12Stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v1.0.4";
    sha256 = "126wq8y9gjbzsxhx5sjs00y8r9wwzcswplj8r65ihn09yfkb3039";
  };

  buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
    Carbon Cocoa CoreServices IOKit ScriptingBridge SkyLight
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
