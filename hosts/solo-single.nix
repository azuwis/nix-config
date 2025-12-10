# Nix single user installation:
# ```
# curl -sL https://nixos.org/nix/install | sed '/trap cleanup/d' > install
# bash install --no-channel-add --no-daemon --no-modify-profile
# ```
# Use `--no-modify-profile` to prevent adding nix profile loading script to
# ~/.bash_profile, this file is for login shell, adding nix profile will
# shallow coreutils, etc, may cause problem for original system, such as, Steam
# won't start in desktop mode on Steam Deck
#
# For interactive shell use only, manually add this to ~/.bashrc:
# ```
# if [[ $- = *i* ]]; then
#   if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi
#   exec -l zsh
# fi
# ```

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./solo.nix
  ];

  nix.singleUser = true;
}
