{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk,
  testers,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "macchanger";
  version = "0.2.1-unstable-2025-12-27";

  src = fetchFromGitHub {
    owner = "shilch";
    repo = "macchanger";
    rev = "583593a7194b390adb306f03ca791e018b0f0d0d";
    hash = "sha256-IKwLH8kmBUjK0fAF0iQFs+vzsSZC48fa/t0v0QAFoak=";
  };

  buildInputs = [ apple-sdk ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 755 macchanger $out/bin/macchanger

    runHook postInstall
  '';

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { extraArgs = [ "--version=branch=v0.2-draft2" ]; };
  };

  meta = {
    description = "macchanger for macOS - Spoof / Fake MAC address";
    homepage = "https://github.com/shilch/macchanger";
    mainProgram = "macchanger";
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.darwin;
  };
})
