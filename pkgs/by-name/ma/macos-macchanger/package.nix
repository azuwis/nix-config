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
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "shilch";
    repo = "macchanger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZewHS5CEodKXjCwlZeoOKgj7rP+rgGCZXzQGAeeAfvk=";
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
    updateScript = nix-update-script { };
  };

  meta = {
    description = "macchanger for macOS - Spoof / Fake MAC address";
    homepage = "https://github.com/shilch/macchanger";
    mainProgram = "macchanger";
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.darwin;
  };
})
