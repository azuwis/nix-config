{ config, lib, pkgs, ... }:

{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.my.user ])
    ./my.nix
    ./system.nix
    ./registry.nix
  ];

  hm.imports = [
    ./difftastic.nix
    ./direnv.nix
    ./helix.nix
    ./git.nix
    ./gitui.nix
    ./gnupg.nix
    ./my.nix
    ./neovim
    ./nnn
    ./nix-index.nix
    ./packages.nix
    ./zsh.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  hm = {
    home.stateVersion = "22.05";
    systemd.user.startServices = "sd-switch";
  };
}
