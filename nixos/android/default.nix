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
  };

  config = mkIf cfg.enable {
    programs.adb.enable = true;
    environment.systemPackages = [ pkgs.android-file-transfer ];
    services.udev.extraRules = ''
      # Huawei phones in MTP mode
      SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", ENV{ID_USB_INTERFACES}=="*:ffff00:*", ENV{ID_MEDIA_PLAYER}="1"
    '';
  };
}
