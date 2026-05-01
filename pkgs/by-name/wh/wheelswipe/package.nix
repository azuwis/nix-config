{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wheelswipe";
  version = "0-unstable-2026-04-27";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "wheelswipe";
    rev = "79f388f1c2e03e721c081e4c81c456c92a1507ce";
    hash = "sha256-WVCVQyQGgXcbXgIuhLKPV7KxTlScFQKSHIf/4jw+dCM=";
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
