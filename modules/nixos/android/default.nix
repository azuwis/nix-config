{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkMerge;
  cfg = config.my.android;

in {
  options.my.android = {
    enable = mkEnableOption (mdDoc "android");
    adbusers = mkEnableOption (mdDoc ''
      Whether to add my.user to adbusers group.

      Adb udev rules add uaccess tag to android devices, so logined user will have permission to access Android phones, and don't need to enable this option.
    '');
  };

  config = mkIf cfg.enable (mkMerge [
    ({
      programs.adb.enable = true;
      environment.systemPackages = [ pkgs.android-file-transfer ];
    })

    (mkIf cfg.adbusers{
      users.users.${config.my.user}.extraGroups = [ "adbusers" ];
    })
  ]);
}
