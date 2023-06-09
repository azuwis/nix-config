{ config, lib, pkgs, ... }:

{
  imports = [
    ./firefox.nix
  ];

  hm.imports = [
    ../common/firefox
    ./firefox.nix
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
    ];
  };

}
