{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  networking.useDHCP = false;
  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "21.11";
  users.groups.azuwis = {};
  users.users."${config.my.user}" = {
    extraGroups = [ "wheel" ];
    group = "azuwis";
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}
