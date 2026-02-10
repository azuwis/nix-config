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
    # For manpage
    environment.systemPackages = [ pkgs.netproc ];

    security.wrappers.netproc = {
      source = "${pkgs.netproc}/bin/netproc";
      owner = "root";
      group = "wheel";
      permissions = "u+rx,g+x";
      capabilities = "cap_dac_read_search,cap_net_admin,cap_net_raw,cap_sys_ptrace+ep";
    };
  };
}
