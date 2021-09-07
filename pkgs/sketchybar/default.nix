{ pkgs, lib, clang12Stdenv, fetchFromGitHub }:

clang12Stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "2021-09-07";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "24fd74bc922f2b1841ba7782d5c0f5e018629eee";
    sha256 = "1inb0wgzcj0qr4vkw7rpf5dca40jvbsbydbfcsix3s2zlg8ixng8";
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
