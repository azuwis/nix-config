{ config, lib, pkgs, ... }:

{
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
    ];
  };

}
