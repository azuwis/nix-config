{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.theme;
in
{
  options.my.theme = {
    enable = mkEnableOption "theme";
  };

  config = mkIf cfg.enable {
    home.pointerCursor = {
      name = "Adwaita";
      size = 16;
      package = pkgs.adwaita-icon-theme;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      theme = {
        name = "Adwaita";
        package = pkgs.gnome-themes-extra;
      };
    };

    wayland.windowManager.sway.config.seat."*".xcursor_theme = config.gtk.cursorTheme.name;
  };
}
