{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../inputs;
in

{
  disabledModules = [ ../nixos/steam/default.nix ];

  imports = [
    ../nixos
    (inputs.jovian-nixos.outPath + "/modules")
    ./hardware-steamdeck.nix
  ];

  registry.entries = [ "jovian-nixos" ];

  nixpkgs.overlays = [ (import ../overlays/jovian.nix) ];

  # workaround for efi entry reset after reboot
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  hardware.bluetooth.enable = true;
  # Use dualboot for now, let SteamOS handle microcode update
  hardware.cpu.amd.updateMicrocode = false;

  networking.hostName = "steamdeck";
  # networkmanager is required to complete the first-time setup process
  networking.networkmanager.enable = true;
  networking.useNetworkd = false;

  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    optimise.automatic = false;
  };

  users.groups.deck = {
    gid = 1000;
  };
  users.users.deck = {
    extraGroups = [ "users" ];
    group = "deck";
    isNormalUser = true;
    uid = 1000;
    openssh.authorizedKeys.keys = config.my.keys;
  };

  jovian.devices.steamdeck = {
    enable = true;
    autoUpdate = true;
  };
  jovian.steam = {
    enable = true;
    autoStart = true;
    user = "deck";
  };
  # Not really work for deck, still need overlays/jovian.nix
  programs.steam.fontPackages = with pkgs; [ noto-fonts-cjk-sans ];

  i18n.inputMethod.enable = true;
  i18n.inputMethod.type = "ibus";
  i18n.inputMethod.ibus.engines = [ pkgs.ibus-engines.pinyin ];

  # boot.plymouth = {
  #   enable = true;
  #   theme = "steamos";
  #   themePackages = [ pkgs.steamdeck-hw-theme ];
  # };

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/desktop-managers/plasma6.nix
  # See optionalPackages for excludePackages
  # Package included: konsole kwin-x11 kate dolphin
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.plasma6.enableQt5Integration = false;
  services.xserver.displayManager.startx.enable = true;
  services.xserver.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    aurorae
    plasma-browser-integration
    plasma-workspace-wallpapers
    (lib.getBin qttools)
    ark
    elisa
    gwenview
    okular
    ktexteditor
    khelpcenter
    baloo-widgets
    dolphin-plugins
    spectacle
    ffmpegthumbs
    krdp
  ];
  jovian.steam.desktopSession = "plasmax11";

  # Fix permission of `/`, SteamOS may modify dir permission of the SD card
  # mount point, and make SSHD refuce any user to login.
  systemd.tmpfiles.rules = [
    "z / 0755 root root"
  ];

  my.nix-builder-client.enable = true;
  theme.enable = true;
  # Proton is not sandboxed, https://github.com/ValveSoftware/Proton/issues/3979
  # It even mounts the SD card, and expose it to all games.
  # SteamOS deck user use uid 1000, create another user with different uid,
  # so at least games do not have read permission of my.user's HOME dir.
  my.uid = lib.mkForce 2000;
}
