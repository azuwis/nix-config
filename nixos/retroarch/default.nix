{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.my.retroarch;
in
{
  options.my.retroarch = {
    enable = mkEnableOption "retroarch";
    cores = mkOption {
      type = types.listOf types.package;
      default = with pkgs.libretro; [
        genesis-plus-gx
        nestopia
      ];
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ (retroarch.override { cores = cfg.cores; }) ];
  };
}
