{ config, lib, pkgs, ... }:

{
  imports = [
    ./common/my.nix
    ./common/system.nix
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${config.my.user} = { imports = [
        ./common/difftastic.nix
        ./common/direnv.nix
        ./common/git.nix
        ./common/gnupg.nix
        ./common/mpv.nix
        ./common/my.nix
        ./common/neovim
        ./common/nnn
        ./common/nix-index.nix
        ./common/packages.nix
        ./common/zsh.nix
      ]; };
    }
  ];
}
