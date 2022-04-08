{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./system.nix
    ../modules/qbittorrent
    inputs.home.nixosModules.home-manager
    {
      home-manager.users.${config.my.user} = { imports = [
        ./packages.nix
      ]; };
    }
  ];
}
