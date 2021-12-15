{ pkgs, config, ... }:

{
  # nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
  # nix-channel --add https://github.com/t184256/nix-on-droid/archive/master.tar.gz nix-on-droid
  # nix-channel --add https://nixos.org/channels/nixos-21.11 nixpkgs
  imports = [
    ./droid/sshd.nix
    ./droid/system.nix
    ./droid/termux.nix
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
      ./droid/compat.nix
      ./droid/gnupg.nix
      ./droid/packages.nix
    ];
  };
}
