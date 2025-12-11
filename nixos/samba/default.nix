{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.samba;
in

{
  options.services.samba = {
    enhance = lib.mkEnableOption "and enhance samba";
  };

  config = lib.mkIf cfg.enhance {
    services.samba = {
      enable = true;
      nmbd.enable = false;
      winbindd.enable = false;
      openFirewall = true;
    };
  };
}
