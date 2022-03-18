{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./nixos/system.nix
    ./modules/qbittorrent
    inputs.home.nixosModules.home-manager
    {
      home-manager.users.${config.my.user} = { imports = [
        ./nixos/packages.nix
      ]; };
    }
  ];
}
