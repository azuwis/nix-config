{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption;
  cfg = config.my.jslisten;
  ini = pkgs.formats.ini { };

  configFile = ini.generate "jslisten.ini" cfg.settings;
  sway = config.my.sway.enable;
in
{
  options.my.jslisten = {
    enable = mkEnableOption "jslisten";

    settings = mkOption {
      type = ini.type;
      default =
        let
          # `program` only accept 100 chars, shorten them by wrapping
          sway-run = args: "${pkgs.writeShellScript (builtins.elemAt (builtins.split " " args) 0) ''
            exec ${./scripts}/sway-run ${args}
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
            program = if sway then sway-run "BotW app_id=info.cemu.Cemu cemu --fullscreen --title-id 00050000101c9300" else "${./scripts}/i3-botw &";
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
    home.packages = [ pkgs.jslisten ];

    home.file.".jslisten".source = configFile;
    home.file.".jslisten".onChange = "/run/current-system/sw/bin/systemctl --user restart jslisten";

    systemd.user.services.jslisten = {
      Unit = {
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.jslisten}/bin/jslisten --mode hold --loglevel notice";
        Environment = "PATH=%h/.nix-profile/bin:/etc/profiles/per-user/%u/bin:/run/current-system/sw/bin";
        Restart = "on-failure";
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    # wayland.windowManager.sway.config.startup = [{ command = "jslisten --mode hold --loglevel notice"; }];
    # xsession.windowManager.i3.config.startup = [{ command = "jslisten --mode hold --loglevel notice"; }];
  };
}
