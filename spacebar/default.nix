{ config, lib, pkgs, ... }:

{
  environment.etc.spacebar.source = ./etc;
  services.spacebar.enable = true;
  services.spacebar.package = pkgs.spacebar;
  services.spacebar.extraConfig = builtins.readFile ./init.sh;
  services.yabai.config.external_bar = "main:24:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  # launchd.user.agents.spacebar.serviceConfig = {
  #   StandardErrorPath = "/tmp/spacebar.log";
  #   StandardOutPath = "/tmp/spacebar.log";
  # };
}
