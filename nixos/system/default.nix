{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = lib.mkIf
        (builtins.hasAttr "/boot/efi" config.fileSystems &&
          config.fileSystems."/boot/efi".fsType == "vfat")
        "/boot/efi";
    };
    grub = {
      device = "nodev";
      efiSupport = true;
    };
  };
  # explicitly enable nixos docs, system like wsl does not enable this
  documentation.nixos.enable = true;
  networking.enableIPv6 = false;
  networking.nftables.enable = true;
  networking.useNetworkd = lib.mkDefault true;
  systemd.network.wait-online.anyInterface = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  # nix.settings.allowed-users = [ config.my.user ];
  programs.ssh.startAgent = true;
  # CVE-2023-38408
  programs.ssh.agentPKCS11Whitelist = "''";
  security.sudo = {
    execWheelOnly = true;
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults requiretty
    '';
  };
  services.openssh = {
    enable = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
    };
  };
  # https://wiki.archlinux.org/title/map_scancodes_to_keycodes
  # nix shell nixpkgs#evemu nixpkgs#evtest
  # sudo evemu-describe
  # sudo evtest | grep EV_MSC
  # sudo udevadm trigger
  services.udev.extraHwdb = ''
    # General keyboard, capslock <-> leftctrl
    evdev:atkbd:dmi:*
     KEYBOARD_KEY_1d=capslock
     KEYBOARD_KEY_3a=leftctrl
    
    # Dell XPS13, leftmeta <-> leftalt
    evdev:atkbd:dmi:bvn*:bvr*:bd*:svnDell*:pnXPS13*:pvr*
     KEYBOARD_KEY_38=leftmeta
     KEYBOARD_KEY_db=leftalt
    
    # Logitech K400 Plus, leftmeta <-> leftalt, capslock <-> leftctrl
    evdev:name:Logitech K400 Plus:dmi:*
     KEYBOARD_KEY_70039=leftctrl
     KEYBOARD_KEY_700e0=capslock
     KEYBOARD_KEY_700e2=leftmeta
     KEYBOARD_KEY_700e3=leftalt

    # Logitech Mechanical keyboard, capslock <-> leftctrl
    evdev:name:Logitech Mechanical keyboard Logitech Mechanical keyboard:dmi:*
     KEYBOARD_KEY_70039=leftctrl
     KEYBOARD_KEY_700e0=capslock

    # Microsoft All-in-One Media Keyboard, capslock <-> leftctrl, delete -> insert
    evdev:name:Microsoft Microsoft® Nano Transceiver v2.0:dmi:*
     KEYBOARD_KEY_70039=leftctrl
     KEYBOARD_KEY_700e0=capslock
     KEYBOARD_KEY_7004c=insert
  '';
  # nix profile diff-closures --profile /nix/var/nix/profiles/system
  system.activationScripts.systemDiff = ''
    # show upgrade diff
    if [ -e /run/current-system ]
    then
      ${pkgs.nix}/bin/nix store --experimental-features nix-command diff-closures /run/current-system "$systemConfig" || true
    fi
  '';
  system.stateVersion = "22.05";
  users.groups.${config.my.user} = {
    gid = config.my.uid;
  };
  users.users.${config.my.user} = {
    extraGroups = [ "wheel" ];
    group = config.my.user;
    isNormalUser = true;
    shell = pkgs.zsh;
    uid = config.my.uid;
    openssh.authorizedKeys.keys = config.my.keys;
  };
}
