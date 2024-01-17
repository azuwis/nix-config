{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.jovian.nixosModules.default
    ./hardware-steamdeck.nix
  ];

  # workaround for efi entry reset after reboot
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "steamdeck";

  my.user = lib.mkForce "deck";
  hm.my.user = lib.mkForce "deck";

  # networkmanager is required to complete the first-time setup process
  networking.networkmanager.enable = true;
  networking.useNetworkd = false;
  users.users.${config.jovian.steam.user}.extraGroups = [ "users" ];

  hardware.bluetooth.enable = true;
  jovian.devices.steamdeck.enable = true;
  jovian.steam = {
    enable = true;
    autoStart = true;
    user = config.my.user;
  };

  my.nix-builder-client.enable = true;
  my.theme.enable = true;
}
