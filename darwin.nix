{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./common/emacs # emacs-all-the-icons-fonts
    ./common/rime
    ./darwin/age.nix
    ./darwin/firefox.nix
    ./darwin/homebrew.nix
    ./darwin/hostname.nix
    ./darwin/kitty.nix # sudo keep TERMINFO_DIRS env
    ./darwin/my.nix
    ./darwin/scinet
    ./darwin/sketchybar
    ./darwin/skhd.nix
    ./darwin/sudo.nix
    ./darwin/system.nix
    ./darwin/wireguard.nix
    ./darwin/yabai.nix
    ./modules/age
    ./modules/scidns
    ./modules/sciroute
    ./modules/shadowsocks
    ./modules/sketchybar
    inputs.home.darwinModules.home-manager
    {
      home-manager.users.${config.my.user} = { imports = [
        ./common/alacritty.nix
        ./common/emacs
        ./common/firefox
        ./common/rime
        ./common/zsh-ssh-agent.nix
        ./darwin/firefox.nix
        ./darwin/hmapps.nix
        ./darwin/kitty.nix
        ./darwin/packages.nix
        ./darwin/skhd.nix
      ]; };
    }
  ];
}
