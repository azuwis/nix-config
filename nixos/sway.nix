{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

let
  fuzzelWrapped = with pkgs; runCommand "fuzzel" { buildInputs = [ makeWrapper ]; } ''
    options="--lines=8 --no-icons --font=monospace:pixelsize=20 --background-color=2E3440FF --text-color=D8DEE9FF --selection-color=4C566AFF --selection-text-color=E8DEE9FF --terminal=footclient --log-level=error"
    makeWrapper ${fuzzel}/bin/fuzzel $out/bin/fuzzel --add-flags "$options"
    # for passmenu
    makeWrapper ${fuzzel}/bin/fuzzel $out/bin/dmenu-wl --add-flags "--dmenu $options"
  '';
in

{
  imports = [
    ./cliphist.nix
    ./foot.nix
    ./yambar
  ];

  home.packages = with pkgs; [
    fuzzelWrapped
    pulsemixer
    swappy
    sway-contrib.grimshot
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    config = {
      # Apps
      # swaymsg -t get_tree
      assigns = {
        "2" = [{ app_id = "^firefox$"; }];
      };
      floating.criteria = [
        { app_id = "^mpv$"; }
      ];
      # Border
      gaps.smartBorders = "no_gaps";
      window.hideEdgeBorders = "both";
      # Keybindings
      menu = "fuzzel";
      keybindings = let mod = config.wayland.windowManager.sway.config.modifier; in lib.mkOptionDefault {
        "${mod}+Tab" = "workspace back_and_forth";
        # stop graphical-session.target so services like foot will not try to restart itself
        "${mod}+Shift+e" = "exec swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'systemctl --user stop graphical-session.target; swaymsg exit'";
        "${mod}+c" = "floating enable; move absolute position center";
        "Print" = "grimshot save - | swappy -f -";
        "XF86AudioRaiseVolume" = "exec pulsemixer --change-volume +3";
        "XF86AudioLowerVolume" = "exec pulsemixer --change-volume -3";
        "XF86AudioMute" = "exec pulsemixer --toggle-mute";
      };
      # Inputs/outputs
      input = {
        "*" = {
          natural_scroll = "enabled";
        };
        "type:keyboard" = {
          repeat_delay = "300";
          repeat_rate = "33";
        };
        "type:touchpad" = {
          accel_profile = "adaptive";
          drag_lock = "enabled";
          dwt = "enabled";
          pointer_accel = "0.28";
          tap = "enabled";
          scroll_method = "edge";
          scroll_factor = "0.6";
        };
      };
      output."*".bg = "#2E3440 solid_color";
      # startup = [{
      #   command = "systemctl --user start xdg-autostart-if-no-desktop-manager.target";
      # }];
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
    extraPackages = with pkgs; [
      qt5.qtwayland
    ];
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland-egl
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };
  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
