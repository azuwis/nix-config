{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation (finalAttrs: {
  pname = "hwheel2swipe";
  version = "0-unstable-2025-12-19";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "hwheel2swipe";
    rev = "d8a6b50648602cb0c9c00df8fd8605dbe468713c";
    hash = "sha256-6qbJ/lKHjpfeNu9VVudbNS0vH8rLZEqFekhwoO6wmfo=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 755 hwheel2swipe $out/bin/hwheel2swipe

    runHook postInstall
  '';

  meta = {
    description = "Simulate touchpad two-finger swipe from mouse horizontal scroll wheel events";
    homepage = "https://github.com/azuwis/hwheel2swipe";
    mainProgram = "hwheel2swipe";
  };
})
