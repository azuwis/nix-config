{ config, pkgs, lib, ... }:

let
  cfg = config.services.seatd;
in
{
  options.services.seatd = {
    enable = lib.mkEnableOption (lib.mdDoc "seatd");
  };

  config = lib.mkIf cfg.enable {
    users.groups.seatd = { };

    systemd.services.seatd = {
      enable = true;
      description = "Seat management daemon";
      script = "${pkgs.seatd}/bin/seatd -g seatd";
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "1";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
