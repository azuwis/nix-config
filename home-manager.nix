{ config, lib, pkgs, ... }:

{
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users."${config.my.user}" = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      curl
      gnupg
      htop
      hydra-check
      pass
      ripgrep
    ];
  };
}
