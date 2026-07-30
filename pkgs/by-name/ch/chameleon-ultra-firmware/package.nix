{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  bubblewrap,
  emptyDirectory,
  gcc-arm-embedded,
  nrf-command-line-tools,
  nrfutil,
  writableTmpDirAsHomeHook,
  writeClosure,
  writeShellApplication,
  zip,
  nix-update-script,
  deviceType ? "ultra",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chameleon-${deviceType}-firmware";
  version = "2.2.0-unstable-2026-07-28";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "RfidResearchGroup";
    repo = "ChameleonUltra";
    rev = "3d1ffe9b4744c22b594d4c11997851eaabeea3d7";
    hash = "sha256-z94pstP8SYhz4o0dRIRJv7UnE+uf3L3G0qnhV9TXTzk=";
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
    APP_FW_SEMVER = lib.versions.majorMinor finalAttrs.version;
    CURRENT_DEVICE_TYPE = deviceType;
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
      flasherClosure = writeClosure [
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
        while IFS= read -r path; do
          BWRAP_ARGS+=(--ro-bind "$path" "$path")
        done < ${flasherClosure}
        ${lib.getExe bubblewrap} "''${BWRAP_ARGS[@]}" -- ${lib.getExe nrfutil'} device program \
          --firmware "${finalAttrs.finalPackage}/${deviceType}-dfu-app.zip" --traits nordicDfu
      '';
    };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
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
