{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "unstable-2022-12-28";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "yabai";
    # rev = "v${version}";
    rev = "c32a7b13055a8ba000c293856589d14c4f697d41";
    sha256 = "1b9h5gz7c8p1b01dp58wbbdwiv472z261y9grinb094y9xy504a1";
  };

  postPatch = let
    replace = {
      aarch64-darwin = ''--replace "-arch x86_64" ""'';
      x86_64-darwin = ''--replace "-arch arm64e" "" --replace "-arch arm64" ""'';
    }.${stdenv.system};
  in ''
    substituteInPlace makefile ${replace}
  '';

  buildPhase = ''
    PATH=/usr/bin:/bin /usr/bin/make install
  '';

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
