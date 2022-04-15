{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib

then
{
  systemd.user.services.uxplay = {
    Unit = {
      Description = "AirPlay Unix mirroring server";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.uxplay}/bin/uxplay -p";
      Restart = "on-failure";
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  wayland.windowManager.sway.config.window.commands = [{
    criteria = { instance = "uxplay"; };
    command = "fullscreen enable";
  }];
}

else

{
  networking.firewall.allowedTCPPorts = [ 7100 7000 7001 ];
  networking.firewall.allowedUDPPorts = [ 6000 6001 7011 ];

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.enable = true;
    publish.userServices = true;
  };
}
