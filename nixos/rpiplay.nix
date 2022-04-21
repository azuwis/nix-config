{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib

then
{
  systemd.user.services.rpiplay = {
    Unit = {
      Description = "Open-source AirPlay mirroring server";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.rpiplay}/bin/rpiplay";
      Restart = "on-failure";
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  wayland.windowManager.sway.config.window.commands = [{
    criteria = { instance = "rpiplay"; };
    command = "fullscreen enable";
  }];
}

else

{
  networking.firewall.allowedTCPPorts = [ 7000 7100 ];
  networking.firewall.allowedUDPPorts = [ 6000 6001 7011 ];

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.enable = true;
    publish.userServices = true;
  };
}
