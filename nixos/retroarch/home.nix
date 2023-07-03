{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf mkOption types;
  cfg = config.my.retroarch;
in
{
  options.my.retroarch = {
    enable = mkEnableOption (mdDoc "retroarch");
    cores = mkOption {
      type = types.listOf types.package;
      default = with pkgs.libretro; [
        genesis-plus-gx
        nestopia
      ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (retroarch.override {
        cores = cfg.cores;
      })
    ];
  };
}
