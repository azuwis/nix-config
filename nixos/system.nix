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
  system.stateVersion = "22.05";
  users.groups."${config.my.user}" = {
    gid = config.my.uid;
  };
  users.users."${config.my.user}" = {
    extraGroups = [ "wheel" ];
    group = "${config.my.user}";
    isNormalUser = true;
    shell = pkgs.zsh;
    uid = config.my.uid;
    openssh.authorizedKeys.keys = config.my.keys;
  };
}
