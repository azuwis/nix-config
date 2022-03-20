{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  nix.settings.allowed-users = [ "${config.my.user}" ];
  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
  };
  # nix profile diff-closures --profile /nix/var/nix/profiles/system
  system.activationScripts.systemDiff = ''
    # show upgrade diff
    ${pkgs.nix}/bin/nix store --experimental-features nix-command diff-closures /run/current-system "$systemConfig"
  '';
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
