{ config, lib, pkgs, ... }:

{
  imports = [
    ./firefox.nix
    ./theme.nix
  ];

  hm.imports = [
    ../common/firefox
    ../common/mpv
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
