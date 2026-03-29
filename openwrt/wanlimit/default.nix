{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.wanlimit;
in

{
  options.wanlimit = {
    enable = lib.mkEnableOption "wanlimit";
  };

  config = lib.mkIf cfg.enable {
    files.file."etc/firewall.wanlimit.sh".source = ./firewall.wanlimit.sh;
    uci.firewall.wanlimit = {
      ".type" = "include";
      path = "/etc/firewall.wanlimit.sh";
    };
  };
}
