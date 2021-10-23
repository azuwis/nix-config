{ pkgs, config, ... }:

{
  imports = [
    ./droid/system.nix
  ];
  home-manager.config = {
    imports = [
      ./common/direnv.nix
      ./common/git.nix
      ./common/my.nix
      ./common/neovim.nix
      ./common/packages.nix
      ./common/zsh.nix
      ./droid/zsh.nix
    ];
  };
}
