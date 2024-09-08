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
    ;
  cfg = config.my.sway;
in
{
  options.my.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    my.wayland = {
      enable = true;
      session = "sway";
    };

    hm.my.sway.enable = true;

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      # override default extraPackages, packages needed are already setted in my.wayland
      extraPackages = [ ];
    };
  };
}
