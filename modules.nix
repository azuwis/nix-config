{ lib, ... }:

if builtins.hasAttr "hm" lib then

[
  ./common/alacritty.nix
  ./common/direnv.nix
  ./common/git.nix
  ./common/mpv.nix
  ./common/my.nix
  ./common/neovim.nix
  ./common/packages.nix
  ./common/zsh.nix
  ./darwin/emacs
  ./darwin/home-manager-apps.nix
  ./darwin/kitty.nix
  ./darwin/packages.nix
  ./darwin/skhd.nix
  ./darwin/squirrel.nix
]

else

[
  ./common/my.nix
  ./darwin/emacs # emacs-all-the-icons-fonts
  ./darwin/homebrew.nix
  ./darwin/hostname.nix
  ./darwin/kitty.nix # sudo keep TERMINFO_DIRS env
  ./darwin/sketchybar
  ./darwin/skhd.nix
  ./darwin/smartnet.nix
  ./darwin/squirrel.nix
  ./darwin/sudo.nix
  ./darwin/system.nix
  ./darwin/yabai.nix
  ./services/redsocks2
  ./services/shadowsocks
  ./services/sketchybar
  ./services/smartdns
]
