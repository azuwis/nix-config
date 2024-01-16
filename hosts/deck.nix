{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    inputs.deck.nixosModules.default
    ./hardware-deck.nix
  ];

  # workaround for efi entry reset after reboot
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "deck";

  # networkmanager is required to complete the first-time setup process
  networking.networkmanager.enable = true;
  networking.useNetworkd = false;
  users.users.${config.my.user}.extraGroups = [ "networkmanager" ];

  jovian.devices.steamdeck.enable = true;
  jovian.steam = {
    enable = true;
    autoStart = true;
    user = config.my.user;
  };

  nix = {
    distributedBuilds = true;
    buildMachines = [{
      hostName = "builder";
      systems = [ "i686-linux" "x86_64-linux" ];
      protocol = "ssh-ng";
    }];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
