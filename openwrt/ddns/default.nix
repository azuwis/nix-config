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
  };
}
