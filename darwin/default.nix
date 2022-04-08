{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ../common/emacs # emacs-all-the-icons-fonts
    ../common/rime
    ../modules/age
    ../modules/scidns
    ../modules/sciroute
    ../modules/shadowsocks
    ../modules/sketchybar
    ./age.nix
    ./firefox.nix
    ./homebrew.nix
    ./hostname.nix
    ./kitty.nix # sudo keep TERMINFO_DIRS env
    ./my.nix
    ./scinet
    ./sketchybar
    ./skhd.nix
    ./sudo.nix
    ./system.nix
    ./wireguard.nix
    ./yabai.nix
    inputs.home.darwinModules.home-manager
    {
      home-manager.users.${config.my.user} = { imports = [
        ../common/alacritty.nix
        ../common/emacs
        ../common/firefox
        ../common/rime
        ../common/zsh-ssh-agent.nix
        ./firefox.nix
        ./hmapps.nix
        ./kitty.nix
        ./packages.nix
        ./skhd.nix
      ]; };
    }
  ];
}
