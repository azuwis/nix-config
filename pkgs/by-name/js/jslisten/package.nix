{
  lib,
  stdenv,
  fetchFromGitHub,
  udev,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "jslisten";
  version = "0-unstable-2023-08-07";

  src = fetchFromGitHub {
    owner = "azuwis";
    repo = "jslisten";
    rev = "d79128689746be2fdaa37fa665068c538e3b8099";
    hash = "sha256-qThNPzdddlBWLd3RTSer3auxQ5E/zHFTCAagSvvRwwM=";
  };

  buildInputs = [ udev ];

  installPhase = ''
    runHook preInstall

    install -D bin/jslisten $out/bin/jslisten

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Listen to gamepad inputs and trigger a command";
    homepage = "https://github.com/workinghard/jslisten";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ azuwis ];
    platforms = platforms.linux;
  };
}
