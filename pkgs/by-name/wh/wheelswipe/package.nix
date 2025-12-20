{
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wheelswipe";
  version = "0-unstable-2025-12-20";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "wheelswipe";
    rev = "452ea4238b423086ceb6b36060aaf10531322561";
    hash = "sha256-eSTcZuZXN2meNFxER1RzpbxbkuTSFKIS5DZ/3DCzgfE=";
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
