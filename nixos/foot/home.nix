{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.foot;

in
{
  options.my.foot = {
    enable = mkEnableOption (mdDoc "foot");
  };

  config = mkIf cfg.enable {
    my.sway.tmenu = "footclient --app-id tmenu --window-size-chars 50x10";

    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = lib.mkDefault "monospace:pixelsize=20";
          include = "${pkgs.fetchurl {
            url = "https://codeberg.org/dnkl/foot/raw/commit/a1796ba5cd1cc7b6ef03021d7db57503e445b5dd/themes/nord";
            sha256 = "sha256-YBoRdklYm2nK9xdypxNZFTloJ3xhKH0d4MvykGUP3i0=";
          }}";
          term = "xterm-256color";
        };
      };
    };

    wayland.windowManager.sway.config = {
      startup = [{ command = "foot --server --log-level=error"; }];
      terminal = "footclient";
    };

  };
}
