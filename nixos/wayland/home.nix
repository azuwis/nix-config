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
    mkOption
    types
    ;
  cfg = config.my.wayland;
in
{
  options.my.wayland = {
    enable = mkEnableOption "wayland";

    terminal = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "monospace:pixelsize=20";
          icons-enabled = false;
          lines = 8;
          terminal = cfg.terminal;
        };
        colors = {
          background = "2e3440ff";
          text = "d8dee9ff";
          selection = "4c566aff";
          selection-text = "e8dee9ff";
        };
      };
    };

    home.packages = with pkgs; [
      (writeShellScriptBin "blurlock" ''
        image=''${XDG_RUNTIME_DIR:-$HOME/.cache}/blurlock.png
        grim - | magick - -scale 10% -scale 1000% "$image"
        swaylock --daemonize --image "$image"
        rm "$image"
      '')
      (writeShellScriptBin "swaylockx" ''
        pkill -x -USR1 swayidle || blurlock
      '')
      grim
    ];

    programs.swaylock = {
      enable = true;
      settings = {
        color = "2E3440";
        font-size = 24;
        ignore-empty-password = true;
        indicator-idle-visible = true;
        indicator-radius = 100;
        show-failed-attempts = true;
      };
    };
  };
}
