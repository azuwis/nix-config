{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.ipv6;
in

{
  options.ipv6 = {
    enable = lib.mkEnableOption "ipv6" // {
      default = true;
    };
  };

  config = lib.mkIf (!cfg.enable) {
    files.file."etc/sysctl.conf".text = ''
      net.ipv6.conf.default.disable_ipv6=1
    '';
  };
}
