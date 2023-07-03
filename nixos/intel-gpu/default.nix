{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.intelGpu;

in
{
  options.my.intelGpu = {
    enable = mkEnableOption (mdDoc "intelGpu");
  };

  config = mkIf cfg.enable {
    hardware.opengl.extraPackages = with pkgs; [
      vaapiIntel
    ];
  };
}
