{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.samba;
in
{
  options.my.samba = {
    enable = mkEnableOption "samba";
  };

  config = mkIf cfg.enable {
    services.samba = {
      enable = true;
      nmbd.enable = false;
      winbindd.enable = false;
      openFirewall = true;
    };
  };
}
