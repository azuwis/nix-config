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
  };
}
