{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../home/darwin
    ./age.nix
    ./emacs.nix # emacs-all-the-icons-fonts
    ./firefox.nix
    ./homebrew.nix
    ./hostname.nix
    ./kitty.nix # sudo keep TERMINFO_DIRS env
    ./my.nix
    ./rime.nix
    ./sketchybar
    ./skhd.nix
    ./smartnet.nix
    ./sudo.nix
    ./system.nix
    ./wireguard.nix
    ./yabai.nix
    ../modules/agenix
    ../modules/redsocks2
    ../modules/shadowsocks
    ../modules/sketchybar
    ../modules/smartdns
  ];
}
