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
          fruit =
            app:
            run {
              inherit app;
              app_id = "onion.torzu_emu.torzu";
              class = "yuzu";
              cmd = if app == "Fruit" then "yuzu" else "yuzu -f -g $HOME/Games/Switch/${app}.nsp";
            };
          # `program` only accept 100 chars, shorten them by wrapping
          run =
            args:
            let
              makeWrapperArgs = lib.flatten (
                lib.mapAttrsToList (name: value: [
                  "--set"
                  (lib.toUpper name)
                  value
                ]) args
              );
              wrapper =
                pkgs.runCommand args.app
                  {
                    nativeBuildInputs = [
                      pkgs.makeWrapper
                    ];
                  }
                  ''
                    makeWrapper "${./scripts}/run.sh" "$out" ${lib.escapeShellArgs makeWrapperArgs}
                  '';
            in
            "${wrapper} &";
          type = args: "${./scripts}/type.sh ${args} &";
        in
        {
          # PS+L
          Left = {
            button1 = 10;
            button2 = 4;
            program = type "Left";
          };
          # PS+R
          Right = {
            button1 = 10;
            button2 = 5;
            program = type "Right";
          };
          # PS+ZL
          Moonlight = {
            button1 = 10;
            button2 = 6;
            # program = sway-run "Dummy app_id=com.moonlight_stream.Moonlight moonlight";
            program = run {
              app = "Moonlight";
              app_id = "com.moonlight_stream.Moonlight";
              class = "Moonlight";
              cmd = "moonlight";
            };
          };
          # PS+ZR
          Space = {
            button1 = 10;
            button2 = 7;
            program = type "space";
          };
          # PS+△
          TotK = {
            button1 = 10;
            button2 = 2;
            program = fruit "TotK";
          };
          # PS+□
          Yuzu = {
            button1 = 10;
            button2 = 3;
            program = fruit "Fruit";
          };
          # PS+○
          BotW = {
            button1 = 10;
            button2 = 1;
            program = run {
              app = "BotW";
              app_id = "info.cemu.Cemu";
              class = "Cemu";
              cmd = "cemu --fullscreen --title-id 00050000101c9300";
            };
          };
          # PS+X
          NieR = {
            button1 = 10;
            button2 = 0;
            program = fruit "NieR";
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
