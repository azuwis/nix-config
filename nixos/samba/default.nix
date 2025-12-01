{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.services.samba;
in
{
  config = mkIf cfg.enable {
    services.samba = {
      nmbd.enable = false;
      winbindd.enable = false;
      openFirewall = true;
    };
  };
}
