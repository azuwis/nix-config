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
  bubblewrap,
  writeClosure,
  writeShellApplication,
  nix-update-script,
  deviceType ? "ultra",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chameleon-${deviceType}-firmware";
  version = "dev-unstable-2026-02-06";

  src = fetchFromGitHub {
    owner = "RfidResearchGroup";
    repo = "ChameleonUltra";
    rev = "2c7c3eeb4df8eee7451aff7c5ddae5d10cd0c34d";
    hash = "sha256-edYdDejaQ89+U3m/CtbUiUh3a3dl7HZqJ7RTwryyM3w=";
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

  passthru.flasher =
    let
      closureInfo = writeClosure [
        finalAttrs.finalPackage
        nrfutil'
      ];
      nrfutil' = (
        nrfutil.override {
          extensions = [ "nrfutil-device" ];
          segger-jlink-headless = emptyDirectory;
        }
      );
    in
    writeShellApplication {
      name = "chameleon-${deviceType}-firmware-flasher";

      text = ''
        BWRAP_ARGS=(
          --unshare-all
          --clearenv --setenv HOME "/tmp"
          --proc /proc
          --ro-bind /sys/bus/usb/devices /sys/bus/usb/devices
          --ro-bind /sys/class/tty /sys/class/tty
          --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
        )
        for path in /dev/ttyACM*; do
          BWRAP_ARGS+=(--dev-bind "$path" "$path")
        done
        mapfile -t paths <${closureInfo}
        for path in "''${paths[@]}"; do
          BWRAP_ARGS+=(--ro-bind "$path" "$path")
        done
        ${lib.getExe bubblewrap} "''${BWRAP_ARGS[@]}" -- ${lib.getExe nrfutil'} device program \
          --firmware "${finalAttrs.finalPackage}/${deviceType}-dfu-app.zip" --traits nordicDfu
      '';
    };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      # https://github.com/RfidResearchGroup/ChameleonUltra/pull/307
      # "--version=branch=pull/307/merge"
      # "--version-regex=v(.*)"
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
