{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.theme;
in
{
  options.theme = {
    enable = mkEnableOption "theme";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
    ];
    xdg.icons.fallbackCursorThemes = [ "Adwaita" ];

    # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland

    # Use dark theme
    #
    # `Adwaita:dark`, gtk3 builtin, only works in GTK_THEME env var, works without gnome-themes-extra
    #
    # environment.sessionVariables.GTK_THEME = "Adwaita:dark";
    #
    # `Adwaita-dark` is provided in gnome-themes-extra, support gtk2/gtk3
    #
    # environment.systemPackages = with pkgs; [
    #   gnome-themes-extra
    # ];
    # programs.dconf.profiles.user.databases = [
    #   {
    #     settings."org/gnome/desktop/interface" = {
    #       color-scheme = "prefer-dark";
    #       gtk-application-prefer-dark-theme = true;
    #       gtk-theme = "Adwaita-dark";
    #     };
    #   }
    # ];

    fonts = {
      enableDefaultPackages = false;
      packages = with pkgs; [
        fira
        nerd-fonts.jetbrains-mono
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        poly
        # for symbol like https://github.com/maralorn/nix-output-monitor
        unifont
      ];
      fontconfig.defaultFonts = {
        sansSerif = [
          "Fira Sans"
          "Noto Sans CJK SC"
        ];
        serif = [
          "Poly"
          "Noto Serif CJK SC"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono CJK SC"
        ];
      };
    };

    qt = {
      enable = true;
    };
    environment.sessionVariables.QT_QPA_PLATFORMTHEME = lib.mkIf (
      !config.services.desktopManager.plasma6.enable
    ) "gtk3";
  };
}
