{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  networking.useDHCP = false;
  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
  };
  system.stateVersion = "21.11";
  users.groups."${config.my.user}" = {
    gid = config.my.uid;
  };
  users.users."${config.my.user}" = {
    extraGroups = [ "wheel" ];
    group = "azuwis";
    isNormalUser = true;
    shell = pkgs.zsh;
    uid = config.my.uid;
  };
}
