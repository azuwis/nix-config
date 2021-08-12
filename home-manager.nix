{ config, pkgs, ... }:

{
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users."${config.my.user}" = {
    home.packages = with pkgs; [
      ripgrep
    ];
  };
}
