{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.ddns;
in

{
  options.ddns = {
    enable = lib.mkEnableOption "ddns";
  };

  config = lib.mkIf cfg.enable {
    builder.packages = [
      "ca-bundle"
      "ddns-scripts"
    ];
    sops.uciKeys = [ ''^ddns\.service_'' ];
    uci.ddns = {
      myddns_ipv4.".type" = "-";
      myddns_ipv6.".type" = "-";
    };
  };
}
