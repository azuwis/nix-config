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
  version = "0-unstable-2025-04-05";

  src = fetchFromGitHub {
    owner = "shilch";
    repo = "macchanger";
    rev = "fd253f2df97f6f42421b9fc002f827012b5ecf72";
    hash = "sha256-Y4hhmuELvVOzOGF3CbWWQedA5OPNSTY+Ur6rwcuOQl0=";
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
