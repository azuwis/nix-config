{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.theme;

in {
  options.my.theme = {
    enable = mkEnableOption (mdDoc "theme");
  };

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };
      cursorTheme = {
        name = "Adwaita";
        size = 16;
      };
      theme = {
        name = "Adwaita";
        package = pkgs.gnome.gnome-themes-extra;
      };
    };

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = {
        name = "adwaita";
        package = pkgs.adwaita-qt;
      };
    };

    wayland.windowManager.sway.config.seat."*".xcursor_theme = config.gtk.cursorTheme.name;
  };
}
