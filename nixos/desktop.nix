{ config, lib, pkgs, ... }:

{
  imports = [
    ./fcitx5
    ./firefox.nix
    ./theme.nix
  ];

  hm.imports = [
    ../common/firefox
    ../common/mpv
    ./fcitx5
    ./firefox.nix
    ./theme.nix
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
    ];
  };

}
