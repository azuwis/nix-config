{ config, lib, pkgs, ... }:

{
  home-manager.users.${config.my.user} = { imports = [
    ./firefox
    ./mpv.nix
    ./rime
  ]; };
}
