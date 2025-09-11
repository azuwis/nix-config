{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkOption;
  cfg = config.programs.jslisten;
  ini = pkgs.formats.ini { };

  configFile = ini.generate "jslisten.ini" cfg.settings;
  sway = config.programs.sway.enable;
in
{
  options.programs.jslisten = {
    enable = mkEnableOption "jslisten";

    settings = mkOption {
      type = ini.type;
      default =
        let
          # `program` only accept 100 chars, shorten them by wrapping
          sway-run =
            args:
            "${pkgs.writeShellScript (builtins.elemAt (builtins.split " " args) 0) ''
              exec ${./scripts}/sway-run.sh ${args}
            ''} &";
        in
        {
          # PS+L
          Left = {
            button1 = 10;
            button2 = 4;
            program = if sway then "wtype -k left &" else "xdotool key Left &";
          };
          # PS+R
          Right = {
            button1 = 10;
            button2 = 5;
            program = if sway then "wtype -k right &" else "xdotool key Right &";
          };
          # PS+ZL
          Moonlight = {
            button1 = 10;
            button2 = 6;
            program = sway-run "Dummy app_id=com.moonlight_stream.Moonlight moonlight";
          };
          # PS+ZR
          Space = {
            button1 = 10;
            button2 = 7;
            program = if sway then "wtype -k space &" else "xdotool key space &";
          };
          # PS+△
          TotK = {
            button1 = 10;
            button2 = 2;
            program = sway-run "TotK class=yuzu yuzu -f -g $HOME/Games/Switch/TotK.nsp";
          };
          # PS+□
          Yuzu = {
            button1 = 10;
            button2 = 3;
            program = sway-run "Yuzu class=yuzu yuzu";
          };
          # PS+○
          BotW = {
            button1 = 10;
            button2 = 1;
            program =
              if sway then
                sway-run "BotW app_id=info.cemu.Cemu cemu --fullscreen --title-id 00050000101c9300"
              else
                "${./scripts}/i3-botw.sh &";
          };
          # PS+X
          NieR = {
            button1 = 10;
            button2 = 0;
            program = sway-run "NieR class=yuzu yuzu -f -g $HOME/Games/Switch/NieR.nsp";
          };
        };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.jslisten ];

    environment.etc."jslisten".source = configFile;

    programs.wayland.startup.jslisten = [
      "jslisten"
      "--mode"
      "hold"
      "--loglevel"
      "notice"
    ];
  };
}
