{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.android;
in
{
  options.programs.android = {
    enable = mkEnableOption "android";
    adbusers = mkEnableOption ''
      Whether to add my.user to adbusers group.

      Adb udev rules add uaccess tag to android devices, so logined user will have permission to access Android phones, and don't need to enable this option.
    '';
  };

  config = mkIf cfg.enable {
    programs.adb.enable = true;
    environment.systemPackages = [ pkgs.android-file-transfer ];
    users.users.${config.my.user}.extraGroups = mkIf cfg.adbusers [ "adbusers" ];
  };
}
