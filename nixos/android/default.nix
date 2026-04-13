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
    environment.systemPackages = [
      pkgs.android-file-transfer
      pkgs.android-tools
    ];
    # Grant uaccess to MTP devices
    services.udev.packages = [ pkgs.libmtp.out ];
  };
}
