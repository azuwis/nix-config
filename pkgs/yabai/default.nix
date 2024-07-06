{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "yabai";
  version = "unstable-2023-05-16";

  src = fetchFromGitHub {
    owner = "koekeishiya";
    repo = "yabai";
    # rev = "v${version}";
    rev = "4d81baf14f7219ed2d929761fed1186bcd793b29";
    sha256 = "03qmwk0qb9wzh6nlk06zb3r1ff6abw3xawdhxbmis98678zwkzh7";
  };

  postPatch =
    let
      replace =
        {
          aarch64-darwin = ''--replace-fail "-arch x86_64" ""'';
          x86_64-darwin = ''--replace-fail "-arch arm64e" "" --replace-fail "-arch arm64" ""'';
        }
        .${stdenv.system};
    in
    ''
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
    maintainers = with maintainers; [
      cmacrae
      shardy
    ];
    license = licenses.mit;
  };
}
