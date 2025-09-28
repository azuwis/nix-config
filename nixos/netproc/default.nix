{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.netproc;
in
{
  options.programs.netproc = {
    enable = mkEnableOption "netproc" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    security.wrappers.netproc = {
      source = "${pkgs.netproc}/bin/netproc";
      owner = "root";
      group = "wheel";
      permissions = "0750";
      capabilities = "cap_net_admin,cap_net_raw=ep";
    };
  };
}
