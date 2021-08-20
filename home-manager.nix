{ config, lib, pkgs, ... }:

{
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users."${config.my.user}" = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      coreutils-full
      curl
      gnupg
      htop
      hydra-check
      pass-otp
      ripgrep
    ];
  };
}
