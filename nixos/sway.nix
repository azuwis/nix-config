{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  home.packages = with pkgs; [
    pulsemixer
  ];

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        dpi-aware = "no";
        font = lib.mkDefault "monospace:size=12";
        include = "${pkgs.fetchurl {
          url = "https://codeberg.org/dnkl/foot/raw/commit/a1796ba5cd1cc7b6ef03021d7db57503e445b5dd/themes/nord";
          sha256 = "sha256-YBoRdklYm2nK9xdypxNZFTloJ3xhKH0d4MvykGUP3i0=";
        }}";
      };
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    package = null;
    config = {
      gaps.smartBorders = "no_gaps";
      menu = "${pkgs.fuzzel}/bin/fuzzel --lines=8 --no-icons --background-color=2E3440FF --text-color=D8DEE9FF --selection-color=4C566AFF --selection-text-color=E8DEE9FF --log-level=error";
      output."*".bg = "#2E3440 solid_color";
      terminal = "footclient";
      window.hideEdgeBorders = "both";
    };
  };

  xsession.pointerCursor = {
    name = "Vanilla-DMZ-AA";
    package = pkgs.vanilla-dmz;
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
