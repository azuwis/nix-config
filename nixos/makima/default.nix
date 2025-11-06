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
          dualsense = {
            remap = {
              # PS+L
              BTN_MODE-BTN_TL = [ "KEY_UP" ];
              # PS+R
              BTN_MODE-BTN_TR = [ "KEY_DOWN" ];
              # PS+ZL
              BTN_MODE-BTN_TL2 = [ "KEY_LEFT" ];
              # PS+ZR
              BTN_MODE-BTN_TR2 = [ "KEY_RIGHT" ];
              # PS+□
              BTN_MODE-BTN_START = [ "KEY_BACKSPACE" ];
              # PS+□
              BTN_MODE-BTN_WEST = [ "KEY_SPACE" ];
              # PS+○
              BTN_MODE-BTN_EAST = [ "KEY_ESC" ];
              # PS+X
              BTN_MODE-BTN_SOUTH = [ "KEY_ENTER" ];
            };
            commands = {
              # PS+△
              BTN_MODE-BTN_NORTH = [ "gamefzf" ];
            };
            settings = {
              RSTICK = "cursor";
              RSTICK_ACTIVATION_MODIFIERS = "BTN_MODE";
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
