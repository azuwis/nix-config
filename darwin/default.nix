{ config, lib, pkgs, ... }:

{
  imports = [
    ../common/emacs # emacs-all-the-icons-fonts
    ../common/rime
    ../modules/scidns
    ../modules/sciroute
    ../modules/shadowsocks
    ../modules/sketchybar
    ./age.nix
    ./firefox
    ./homebrew.nix
    ./hostname.nix
    ./kitty # sudo keep TERMINFO_DIRS env
    ./my.nix
    ./scinet
    ./sketchybar
    ./skhd
    ./sudo.nix
    ./system.nix
    ./wireguard.nix
    ./yabai.nix
  ];

  hm.imports = [
    ../common/alacritty.nix
    ../common/emacs
    ../common/firefox
    ../common/mpv
    ../common/rime
    ../common/zsh-ssh-agent.nix
  ] ++ lib.my.genModules ./. "home.nix";
}
