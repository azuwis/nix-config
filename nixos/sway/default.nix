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
    my.wayland.enable = true;

    hm.my.sway.enable = true;

    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      # override default extraPackages, packages needed are already setted in my.wayland
      extraPackages = [ ];
    };

    # https://github.com/swaywm/sway/pull/7226 not yet release, only enable waylandFrontend for sway from nixpkgs-wayland
    i18n.inputMethod.fcitx5.waylandFrontend = lib.hasPrefix "+" config.programs.sway.package.version;
  };
}
