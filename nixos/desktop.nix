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

  hm.home.packages = with pkgs; [
    python3.pkgs.subfinder
    chromium
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
    ];
  };

}
