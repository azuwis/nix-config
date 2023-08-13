{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.theme;

in
{
  options.my.theme = {
    enable = mkEnableOption (mdDoc "theme");
  };

  config = mkIf cfg.enable {
    home.pointerCursor = {
      name = "Adwaita";
      size = 16;
      package = pkgs.gnome.adwaita-icon-theme;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome.adwaita-icon-theme;
      };
      theme = {
        name = "Adwaita";
        package = pkgs.gnome.gnome-themes-extra;
      };
    };

    wayland.windowManager.sway.config.seat."*".xcursor_theme = config.gtk.cursorTheme.name;
  };
}
