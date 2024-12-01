{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  options.my.hass = {
    device_tracker = mkEnableOption "device_tracker";
  };

  config = mkIf (cfg.enable && cfg.device_tracker) {
    services.home-assistant.config.device_tracker = [
      {
        platform = "ubus";
        host = "xr500.lan";
        username = "hass";
        password = "!secret ubus_password";
        dhcp_software = "none";
        consider_home = 60;
        new_device_defaults.track_new_devices = false;
      }
    ];

    hass.automations = ''
      - alias: Primary bedroom movie on
        triggers:
          - trigger: state
            entity_id: device_tracker.epson_projector
            from: "not_home"
            to: "home"
        actions:
          - action: scene.create
            data:
              scene_id: primary_bedroom_before
              snapshot_entities:
                - cover.lumi_hmcn01_7c8c_curtain
                - light.primary_bedroom
          - if:
              - condition: sun
                after: sunrise
                before: sunset
            then:
              - action: cover.set_cover_position
                target:
                  entity_id: cover.lumi_hmcn01_7c8c_curtain
                data:
                  position: 20
          - if:
              - condition: state
                entity_id: light.primary_bedroom
                state: "on"
            then:
              - action: light.turn_on
                target:
                  entity_id: light.primary_bedroom
                data:
                  brightness: 3
          - action: media_player.turn_on
            target:
              entity_id: media_player.edifier_r2000db
          - delay: 2
          - action: media_player.select_source
            target:
              entity_id: media_player.edifier_r2000db
            data:
              source: Bluetooth

      - alias: Primary bedroom movie off
        triggers:
          - trigger: state
            entity_id: device_tracker.epson_projector
            from: "home"
            to: "not_home"
        actions:
          - action: media_player.turn_off
            target:
              entity_id: media_player.edifier_r2000db
          - if:
              - condition: sun
                after: sunrise
                before: sunset
            then:
              - action: scene.turn_on
                target:
                  entity_id: scene.primary_bedroom_before
    '';
  };
}
