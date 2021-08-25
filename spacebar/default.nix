{ config, lib, pkgs, ... }:

let rightShell = ./right-shell.sh;

in {
  services.spacebar.enable = true;
  services.spacebar.package = pkgs.spacebar;
  services.spacebar.extraConfig = builtins.readFile (pkgs.substituteAll {
    src = ./init.sh;
    inherit rightShell;
  });
  services.yabai.config.external_bar = "main:24:0";
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  # launchd.user.agents.spacebar.serviceConfig = {
  #   StandardErrorPath = "/tmp/spacebar.log";
  #   StandardOutPath = "/tmp/spacebar.log";
  # };
}
