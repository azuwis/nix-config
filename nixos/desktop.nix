{ config, lib, pkgs, ...}:

{
  imports = [
    ./fcitx5
    ./sway.nix
    {
      home-manager.users.${config.my.user} = { imports = [
        ../common/mpv.nix
        ./fcitx5
        ./sway.nix
      ]; };
    }
  ];
}
