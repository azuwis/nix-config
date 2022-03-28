{ config, lib, pkgs, ...}:

{
  imports = [
    ./fcitx5
    ./sway.nix
    {
      home-manager.users.${config.my.user} = { imports = [
        ./fcitx5
      ]; };
    }
  ];
}
