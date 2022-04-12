{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  networking.useDHCP = false;
  networking.useNetworkd = true;
  # nix.settings.allowed-users = [ "${config.my.user}" ];
  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
  };
  # run `udevadm trigger` to apply immediately
  services.udev.extraHwdb = ''
    # General keyboard, swap capslock leftctrl
    evdev:atkbd:dmi:*
     KEYBOARD_KEY_1d=capslock
     KEYBOARD_KEY_3a=leftctrl
    
    # Dell XPS13, swap leftmeta leftalt
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnDell*:pnXPS13*:pvr*
     KEYBOARD_KEY_38=leftmeta
     KEYBOARD_KEY_db=leftalt
    
    # Logitech K400 Plus, swap leftmeta leftalt, swap capslock leftctrl
    evdev:name:Logitech K400 Plus:dmi:*
     KEYBOARD_KEY_70039=leftctrl
     KEYBOARD_KEY_700e0=capslock
     KEYBOARD_KEY_700e2=leftmeta
     KEYBOARD_KEY_700e3=leftalt
  '';
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
