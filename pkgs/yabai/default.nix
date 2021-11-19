{ lib, stdenvNoCC, fetchzip }:

stdenvNoCC.mkDerivation rec {
  pname = "yabai";
  version = "4.0.0-1";

  src = fetchzip {
    url = "https://github.com/azuwis/yabai/releases/download/v3.3.10/yabai-v${version}.tar.gz";
    sha256 = "sha256-PHtAZlS+L4SHN86ca1g1RsLzdJYIe6dH5nWabWdtFz0=";
  };

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1/
    cp ./bin/yabai $out/bin/yabai
    cp ./doc/yabai.1 $out/share/man/man1/yabai.1
  '';

  meta = with lib; {
    description = ''
      A tiling window manager for macOS based on binary space partitioning
    '';
    homepage = "https://github.com/koekeishiya/yabai";
    platforms = platforms.darwin;
    maintainers = with maintainers; [ cmacrae shardy ];
    license = licenses.mit;
  };
}
