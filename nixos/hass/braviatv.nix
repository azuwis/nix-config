{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    braviatv = mkEnableOption (mdDoc "braviatv") // { default = true; };
  };

  config = mkIf (cfg.enable && cfg.braviatv) {
    services.home-assistant.extraPackages = ps: [ ps.pybravia ];

    hass.automations = ''
      - alias: TV living room off when light living room off
        trigger:
          - platform: state
            entity_id: light.living_room
            to: "off"
        condition:
          - condition: sun
            after: sunset
            before: sunrise
        action:
          - service: media_player.turn_off
            data:
              entity_id: media_player.sony_kdl_55w800b
    '';
  };
}
