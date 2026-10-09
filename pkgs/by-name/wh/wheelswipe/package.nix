{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wheelswipe";
  version = "0-unstable-2026-10-08";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "wheelswipe";
    rev = "791e8fbb4531fb86bbc811fec0a60267a1ca1912";
    hash = "sha256-mscwxhJWGHK2YH+d0dz0Ev6DSAveSqPTUtSqIy2vdrg=";
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
