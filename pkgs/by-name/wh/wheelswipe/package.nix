{
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
    rev = "d1104a571bac293901351df8d51a98854ea295d9";
    hash = "sha256-f7H5yuRT5Jr1CoN+5HeLp72w38wPZ4EBAHiWG8qidek=";
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
