{ pkgs, config, ... }:

{
  imports = [
    ./droid/system.nix
  ];
  home-manager.config = {
    imports = [
      ./common/direnv.nix
      ./common/git.nix
      ./common/gnupg.nix
      ./common/my.nix
      ./common/neovim.nix
      ./common/packages.nix
      ./common/zsh-ssh-agent.nix
      ./common/zsh.nix
      ./droid/gnupg.nix
      ./droid/packages.nix
      ./droid/zsh.nix
    ];
  };
}
