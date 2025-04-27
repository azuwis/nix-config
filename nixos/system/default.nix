{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  boot.loader = {
    efi = {
      canTouchEfiVariables = lib.mkDefault true;
      efiSysMountPoint = lib.mkIf (
        builtins.hasAttr "/boot/efi" config.fileSystems && config.fileSystems."/boot/efi".fsType == "vfat"
      ) "/boot/efi";
    };
    grub = {
      device = "nodev";
      efiSupport = true;
      backgroundColor = "#000000";
      splashImage = null;
      theme = pkgs.minimal-grub-theme;
      # Remove `--class nixos` to disable icon
      entryOptions = "--unrestricted";
      subEntryOptions = "";
    };
  };
  environment.systemPackages = lib.optionals (config.boot.loader.grub.enable == true) [
    pkgs.grub-reboot-menu
  ];
  # https://github.com/orgs/NixOS/projects/66
  # boot.initrd.systemd.enable = true;
  # explicitly enable nixos docs, system like nixos-wsl does not enable this
  documentation.nixos.enable = true;
  networking.enableIPv6 = false;
  networking.nftables.enable = true;
  networking.useNetworkd = lib.mkDefault true;
  # Route single-label domains to dnsservers
  # https://github.com/systemd/systemd/issues/28054
  # services.resolved.extraConfig = ''
  #   ResolveUnicastSingleLabel=true
  # '';
  # systemd.network.wait-online.anyInterface = config.networking.useDHCP;
  nix.settings.allowed-users = [ config.my.user ];
  nix.channel.enable = false;
  # For nixos-option/nixos-rebuild
  nix.nixPath = [ "nixos-config=/etc/nixos/hosts/${config.networking.hostName}.nix" ];
  programs.ssh.startAgent = true;
  # CVE-2023-38408
  programs.ssh.agentPKCS11Whitelist = "''";
  security.pam.sshAgentAuth.enable = true;
  security.sudo = {
    execWheelOnly = true;
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
  # Switch leftmeta and leftalt, as the window manager global modifier, meta is more often used then alt
  # https://wiki.archlinux.org/title/map_scancodes_to_keycodes
  # nix shell nixpkgs#evemu nixpkgs#evtest
  # sudo evemu-describe
  # sudo evtest | grep EV_MSC
  # sudo udevadm trigger
  # Dell XPS13
  # evdev:atkbd:dmi:bvn*:bvr*:bd*:svnDell*:pnXPS13*:pvr*
  # Logitech K400 Plus
  # evdev:name:Logitech K400 Plus:dmi:*
  services.udev.extraHwdb = ''
    # AT keyboard, capslock <-> leftctrl, leftmeta <-> leftalt
    evdev:atkbd:dmi:*
     KEYBOARD_KEY_1d=capslock
     KEYBOARD_KEY_3a=leftctrl
     KEYBOARD_KEY_38=leftmeta
     KEYBOARD_KEY_db=leftalt

    # USB keyboard, capslock <-> leftctrl, leftmeta <-> leftalt
    evdev:input:b0003v*
     KEYBOARD_KEY_70039=leftctrl
     KEYBOARD_KEY_700e0=capslock
     KEYBOARD_KEY_700e2=leftmeta
     KEYBOARD_KEY_700e3=leftalt

    # Microsoft All-in-One Media Keyboard, delete -> insert
    evdev:name:Microsoft Microsoft® Nano Transceiver v2.0:dmi:*
     KEYBOARD_KEY_7004c=insert
  '';
  # nix profile diff-closures --profile /nix/var/nix/profiles/system
  # system.activationScripts.systemDiff = ''
  #   # show upgrade diff
  #   if [ -e /run/current-system ]
  #   then
  #     ${pkgs.nix}/bin/nix store --experimental-features nix-command diff-closures /run/current-system "$systemConfig" || true
  #   fi
  # '';
  system.stateVersion = "23.11";
  systemd.enableStrictShellChecks = lib.mkDefault true;
  users.groups.${config.my.user} = {
    gid = config.my.uid;
  };
  users.users.${config.my.user} = {
    # `users` is the primary group of all normal users in NixOS
    extraGroups = [
      "users"
      "wheel"
    ];
    group = config.my.user;
    isNormalUser = true;
    shell = pkgs.zsh;
    uid = config.my.uid;
    openssh.authorizedKeys.keys = config.my.keys;
  };
}
