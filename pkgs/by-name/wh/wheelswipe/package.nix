{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wheelswipe";
  version = "0-unstable-2026-03-21";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "wheelswipe";
    rev = "67eb9a03140619f9849b9eb171cc6e3e96418412";
    hash = "sha256-4KHLmryxUkY9uinQkBxbCVIGgUKwvttCvSEPc9Ev5vw=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 755 wheelswipe $out/bin/wheelswipe

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Linux utility that converts horizontal mouse scroll wheel events to touchpad two-finger swipe gestures";
    homepage = "https://github.com/azuwis/wheelswipe";
    mainProgram = "wheelswipe";
    platforms = lib.platforms.linux;
  };
})
