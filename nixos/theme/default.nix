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
    # need by home-manager gtk.enable https://github.com/nix-community/home-manager/issues/3113
    programs.dconf.enable = true;
    hm.my.theme.enable = true;

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

    qt =
      {
        enable = true;
      }
      // lib.optionalAttrs
        (
          !config.services.desktopManager.plasma6.enable
          && !config.services.xserver.desktopManager.plasma5.enable
        )
        {
          platformTheme = "gnome";
          style = "adwaita";
        };
  };
}
