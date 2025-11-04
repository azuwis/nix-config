{
  lib,
  writeShellApplication,
  bubblewrap,
  chameleon-ultra-firmware,
  emptyDirectory,
  nrfutil,
  writeClosure,
}:

let
  closureInfo = writeClosure [
    chameleon-ultra-firmware
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
  name = "chameleon-ultra-firmware-flasher";

  text = ''
    BWRAP_ARGS=(
      --unshare-all
      --clearenv --setenv HOME "$HOME"
      --proc /proc
      --dev-bind-try /dev/ttyACM0 /dev/ttyACM0
      --dev-bind-try /dev/ttyACM1 /dev/ttyACM1
      --ro-bind /sys/bus/usb/devices /sys/bus/usb/devices
      --ro-bind /sys/class/tty /sys/class/tty
      --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00
    )
    mapfile -t paths <${closureInfo}
    for path in "''${paths[@]}"; do
      BWRAP_ARGS+=(--ro-bind "$path" "$path")
    done
    ${lib.getExe bubblewrap} "''${BWRAP_ARGS[@]}" -- ${lib.getExe nrfutil'} device program \
      --firmware "${chameleon-ultra-firmware}/ultra-dfu-app.zip" --traits nordicDfu
  '';
}
