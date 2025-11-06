{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.makima;
  toml = pkgs.formats.toml { };
in

{
  options.programs.makima = {
    enable = lib.mkEnableOption "makima";

    settings = lib.mkOption {
      type = lib.types.attrsOf toml.type;
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
            wrapper;
          dualsense = {
            remap = {
              # PS+L
              BTN_MODE-BTN_TL = [ "KEY_LEFT" ];
              # PS+R
              BTN_MODE-BTN_TR = [ "KEY_RIGHT" ];
              # PS+ZR
              BTN_MODE-BTN_TR2 = [ "KEY_SPACE" ];
            };
            commands = {
              # PS+ZL
              BTN_MODE-BTN_TL2 = [
                (run {
                  app = "Moonlight";
                  app_id = "com.moonlight_stream.Moonlight";
                  class = "Moonlight";
                  cmd = "moonlight";
                })
              ];
              # PS+△
              BTN_MODE-BTN_NORTH = [ (fruit "TotK") ];
              # PS+□
              BTN_MODE-BTN_WEST = [ (fruit "Fruit") ];
              # PS+○
              BTN_MODE-BTN_EAST = [
                (run {
                  app = "BotW";
                  app_id = "info.cemu.Cemu";
                  class = "Cemu";
                  cmd = "cemu --fullscreen --title-id 00050000101c9300";
                })
              ];
              # PS+X
              BTN_MODE-BTN_SOUTH = [ (fruit "NieR") ];
            };
          };
        in
        {
          "DualSense Wireless Controller" = dualsense;
          "Sony Interactive Entertainment DualSense Wireless Controller" = dualsense;
        };
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.uinput.enable = true;
    users.users.${config.my.user}.extraGroups = [ "uinput" ];

    environment.etc = lib.mapAttrs' (name: value: {
      name = "makima/${name}.toml";
      value.source = toml.generate "makima.toml" value;
    }) cfg.settings;

    environment.systemPackages = [
      (pkgs.wrapper {
        package = pkgs.makima;
        env.MAKIMA_CONFIG = "/etc/makima";
      })
    ];

    programs.wayland.startup.makima = [ "makima" ];
  };
}
