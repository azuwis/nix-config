{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  emptyDirectory,
  gcc-arm-embedded,
  nrf-command-line-tools,
  nrfutil,
  writableTmpDirAsHomeHook,
  zip,
  nix-update-script,
  deviceType ? "ultra",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chameleon-${deviceType}-firmware";
  version = "2.1.0-unstable-2025-10-16";

  src = fetchFromGitHub {
    owner = "RfidResearchGroup";
    repo = "ChameleonUltra";
    rev = "100484b30d8cea56b30afa100ad501164eabe88d";
    hash = "sha256-n+S9NhimP587/nvtrsaZalxL0okhqbWGFeWDYjO9gxM=";
  };

  postPatch = ''
    substituteInPlace firmware/Makefile.defs \
      --replace-fail 'GIT_VERSION :=' 'GIT_VERSION ?=' \
      --replace-fail 'APP_FW_SEMVER :=' 'APP_FW_SEMVER ?='
  '';

  nativeBuildInputs = [
    bash
    gcc-arm-embedded
    (nrf-command-line-tools.overrideAttrs {
      # Don't need segger-jlink, only `mergehex` is used
      runtimeDependencies = [ ];
    })
    (nrfutil.override {
      extensions = [ "nrfutil-nrf5sdk-tools" ];
      # segger-jlink-headless is for `nrfutil-device` extension, don't need it for building firmware
      segger-jlink-headless = emptyDirectory;
    })
    writableTmpDirAsHomeHook
    zip
  ];

  env = rec {
    CURRENT_DEVICE_TYPE = deviceType;
    APP_FW_SEMVER = lib.versions.majorMinor finalAttrs.version;
    GIT_VERSION = "v${APP_FW_SEMVER}-1-g${builtins.substring 0 7 finalAttrs.src.rev}";
    GNU_INSTALL_ROOT = "${lib.getBin gcc-arm-embedded}/bin/";
    GNU_VERSION = gcc-arm-embedded.version;
  };

  buildPhase = ''
    runHook preBuild

    echo "APP_FW_SEMVER: $APP_FW_SEMVER"
    echo "GIT_VERSION: $GIT_VERSION"
    bash ./firmware/build.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp firmware/objects/*.zip $out/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      # https://github.com/RfidResearchGroup/ChameleonUltra/pull/307
      "--version=branch=pull/307/merge"
      "--version-regex=v(.*)"
    ];
  };

  meta = {
    description = "Firmware for the Chameleon ${deviceType} device";
    homepage = "https://github.com/RfidResearchGroup/ChameleonUltra";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      azuwis
    ];
    platforms = lib.platforms.linux;
  };
})
