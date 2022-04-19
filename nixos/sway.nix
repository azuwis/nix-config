{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  imports = [
    ./foot.nix
    ./yambar
  ];

  home.packages = with pkgs; [
    pulsemixer
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    config = {
      floating.criteria = [
        { app_id = "^mpv$"; }
      ];
      gaps.smartBorders = "no_gaps";
      menu = "${pkgs.fuzzel}/bin/fuzzel --lines=8 --no-icons --font=monospace:pixelsize=20 --background-color=2E3440FF --text-color=D8DEE9FF --selection-color=4C566AFF --selection-text-color=E8DEE9FF --log-level=error";
      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault {
        "${mod}+Tab" = "workspace back_and_forth";
        # stop graphical-session.target so services like foot will not try to restart itself
        "${mod}+Shift+e" = "exec swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'systemctl --user stop graphical-session.target; swaymsg exit'";
        "${mod}+c" = "floating toggle; move absolute position center";
      };
      output."*".bg = "#2E3440 solid_color";
      window.hideEdgeBorders = "both";
    };
  };

  wayland.windowManager.sway.swaynag = {
    enable = true;
    settings."<config>".edge = "bottom";
  };
}

else

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
    '';
  };
}
