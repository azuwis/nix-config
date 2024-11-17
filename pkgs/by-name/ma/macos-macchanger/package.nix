{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_12,
  testers,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "macchanger";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "shilch";
    repo = "macchanger";
    rev = "v${finalAttrs.version}-draft";
    hash = "sha256-VGTm6cefWxLfajh+zJ6vaGZRXOrw3xJi4P21j3I8ERY=";
  };

  buildInputs = [ apple-sdk_12 ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 755 macchanger $out/bin/macchanger

    runHook postInstall
  '';

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    changelog = "https://github.com/toy/blueutil/blob/main/CHANGELOG.md";
    description = "macchanger for macOS - Spoof / Fake MAC address";
    homepage = "https://github.com/shilch/macchanger";
    mainProgram = "macchanger";
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.darwin;
  };
})
