{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.bluetooth;
in
{
  options.programs.bluetooth = {
    enable = mkEnableOption "bluetooth";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    # Realtek btusb chips (RTL8761B etc.) fail to reinitialize firmware
    # after warm reboot if runtime suspend kicks in.  Launchpad #1968604.
    boot.extraModprobeConfig = ''
      options btusb enable_autosuspend=n
    '';

    environment.systemPackages = [ pkgs.bluetuith ];
  };
}
