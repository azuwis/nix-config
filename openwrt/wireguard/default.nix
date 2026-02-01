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
  };

  config = lib.mkIf cfg.enable {
    builder.packages = [ "wireguard-tools" ];
    files.file."etc/crontabs/root".text = "* * * * * /usr/bin/wireguard_watchdog";
  };
}
