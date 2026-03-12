{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wireguard;
in

{
  options.wireguard = {
    enable = lib.mkEnableOption "wireguard";
    cron = lib.mkEnableOption "wireguard cron";
  };

  config = lib.mkIf cfg.enable {
    builder.packages = [ "wireguard-tools" ];
    files.file."etc/crontabs/root".text = lib.mkIf cfg.cron "* * * * * /usr/bin/wireguard_watchdog";
  };
}
