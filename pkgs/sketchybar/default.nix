{ pkgs, lib, clang12Stdenv, fetchFromGitHub }:

clang12Stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v1.1.1";
    sha256 = "1r34cfbwdn6nnh729bc8vraw1pynadca2vcsb1jxs2asnwr8n7nz";
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
