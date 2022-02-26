{ config, lib, pkgs, ... }:

{
  imports = [
    ./age.nix
    ./agenix.nix
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
    ../modules/redsocks2
    ../modules/shadowsocks
    ../modules/sketchybar
    ../modules/smartdns
  ];
}
