{
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wheelswipe";
  version = "0-unstable-2026-03-11";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "wheelswipe";
    rev = "b3225bce9f1e3e12ec82c698fa20a8ec771020ef";
    hash = "sha256-06yWdyCCC3aRDBzqJZ7G2HegMbbPjt/zql2zwfI+6QI=";
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
  };
})
