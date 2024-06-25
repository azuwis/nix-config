{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    inputs.jovian.nixosModules.default
    ./hardware-steamdeck.nix
  ];

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

  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = [ pkgs.ibus-pinyin ];

  # boot.plymouth = {
  #   enable = true;
  #   theme = "steamos";
  #   themePackages = [ pkgs.steamdeck-hw-theme ];
  # };

  # services.desktopManager.plasma6.enable = true;
  # environment.plasma6.excludePackages = with pkgs.kdePackages; [
  #   ark
  #   elisa
  #   gwenview
  #   kate
  #   khelpcenter
  #   okular
  #   plasma-browser-integration
  #   print-manager
  # ];
  # jovian.steam.desktopSession = "plasma";

  services.xserver.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.startx.enable = true;
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    pkgs.aha
    plasma-browser-integration
    oxygen
  ];
  jovian.steam.desktopSession = "plasma";

  my.nix-builder-client.enable = true;
  my.theme.enable = true;
  # Proton is not sandboxed, https://github.com/ValveSoftware/Proton/issues/3979
  # It even mounts the SD card, and expose it to all games.
  # SteamOS deck user use uid 1000, create another user with different uid,
  # so at least games do not have read permission of my.user's HOME dir.
  my.uid = lib.mkForce 2000;
}
