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
    mkMerge
    mkOption
    types
    ;
  cfg = config.my.niri;
in
{
  options.my.niri = {
    enable = mkEnableOption "niri";

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };

    initlock = mkEnableOption "initlock";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      xdg.configFile."niri/config.kdl".source = pkgs.substituteAll {
        inherit (cfg) extraConfig;
        src = ./config.kdl;
        wallpaper = pkgs.wallpapers.default;
      };
    }

    (mkIf cfg.initlock {
      my.niri.extraConfig = ''
        spawn-at-startup "initlock"
      '';
    })
  ]);
}
