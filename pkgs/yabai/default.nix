{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "yabai";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = pname;
    # rev = "v${version}";
    rev = "c02de22e0c7c653d2048fd15eb1f86677d0f43e5";
    sha256 = "sha256-zo4uDLI1Exmd+Z4pgdVvBfpbIAJ/C+WxlPlxNayzIo0=";
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
