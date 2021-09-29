{ lib, ... }:

if builtins.hasAttr "hm" lib then

[
  ./alacritty.nix
  ./direnv.nix
  ./emacs
  ./git.nix
  ./kitty.nix
  ./mpv.nix
  ./my.nix
  ./neovim.nix
  ./skhd.nix
  ./squirrel.nix
  ./zsh.nix
]

else

[
  <home-manager/nix-darwin>
  ./services/redsocks2
  ./services/shadowsocks
  ./services/sketchybar
  ./services/smartdns
  ./emacs # emacs-all-the-icons-fonts
  ./homebrew.nix
  ./hostname.nix
  ./kitty.nix # sudo keep TERMINFO_DIRS env
  ./my.nix
  ./skhd.nix
  ./smartnet.nix
  ./sketchybar
  ./squirrel.nix
  ./sudo.nix
  ./system.nix
  ./yabai.nix
]
