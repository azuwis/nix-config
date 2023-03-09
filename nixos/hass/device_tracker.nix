{ config, lib, pkgs, ... }:

{
  services.home-assistant.config.device_tracker = [{
    platform = "ubus";
    host = "xr500.lan";
    username = "hass";
    password = "!secret ubus_password";
    dhcp_software = "none";
    consider_home = 60;
    new_device_defaults.track_new_devices = false;
  }];

  hass.automations = ''
    - alias: Primary bedroom movie on
      trigger:
        - platform: state
          entity_id: device_tracker.epson_projector
          from: "not_home"
          to: "home"
      action:
        - service: scene.create
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
          - service: cover.set_cover_position
            data:
              entity_id: cover.lumi_hmcn01_7c8c_curtain
              position: 20
        - if:
            - condition: state
              entity_id: light.primary_bedroom
              state: "on"
          then:
          - service: light.turn_on
            data:
              entity_id: light.primary_bedroom
              brightness: 3
        - service: media_player.turn_on
          data:
            entity_id: media_player.edifier_r2000db
        - delay: 2
        - service: media_player.select_source
          data:
            entity_id: media_player.edifier_r2000db
            source: Bluetooth

    - alias: Primary bedroom movie off
      trigger:
        - platform: state
          entity_id: device_tracker.epson_projector
          from: "home"
          to: "not_home"
      action:
        - service: media_player.turn_off
          data:
            entity_id: media_player.edifier_r2000db
        - if:
            - condition: sun
              after: sunrise
              before: sunset
          then:
            - service: scene.turn_on
              target:
                entity_id: scene.primary_bedroom_before
  '';
}
