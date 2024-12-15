{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.hass;

  mijia_hub_init = pkgs.writeScript "mijia_hub_init" ''
    #!${lib.getExe pkgs.expect} -f
    spawn ${lib.getExe' pkgs.inetutils "telnet"} Mijia_Hub_V2-2531.lan

    expect "login:"
    send "root\r"

    expect "#"
    send "iptables -C INPUT \! --src nuc -m tcp -p tcp --dport 23 -j DROP || iptables -I INPUT \! --src nuc -m tcp -p tcp --dport 23 -j DROP\r"

    expect "#"
    send "exit\r"

    close
  '';
in
{
  options.my.hass = {
    xiaomi_gateway3 = mkEnableOption "xiaomi_gateway3";
  };

  config = mkIf (cfg.enable && cfg.xiaomi_gateway3) {
    services.home-assistant.customComponents = [
      # pkgs.home-assistant-custom-components.xiaomi_gateway3
      pkgs.xiaomi_gateway3
    ];

    services.home-assistant.config = {
      homeassistant.customize_glob = {
        "binary_sensor.*_occupancy".icon = "mdi:motion-sensor";
        "light.*_group".icon = "mdi:lightbulb";
      };
      shell_command.mijia_hub_init = mijia_hub_init;
      # logger.logs."custom_components.xiaomi_gateway3" = "debug";
    };

    hass.automations = ''
      - alias: XiaomiGateway set iptables when start
        triggers:
          - trigger: homeassistant
            event: start
          - trigger: state
            entity_id: binary_sensor.54ef44432531_gateway
            to: "on"
        actions:
          - action: shell_command.mijia_hub_init

      - alias: Button A single click
        triggers:
          - trigger: state
            entity_id: sensor.0x00158d00023d57a9_action
            to: single
        actions:
          - action: light.toggle
            target:
              entity_id: light.yeelink_fancl5_e358_light

      - alias: Light bathroom on when sensor on
        triggers:
          - trigger: state
            entity_id: binary_sensor.dced8387eef4_occupancy
            from: "off"
            to: "on"
        conditions:
          - condition: state
            entity_id: light.bathroom
            state: "off"
        actions:
          - action: light.turn_on
            target:
              entity_id: light.bathroom

      - alias: Light bathroom off when sensor off
        triggers:
          - trigger: state
            entity_id: binary_sensor.dced8387eef4_occupancy
            from: "on"
            to: "off"
        conditions:
          - condition: state
            entity_id: light.bathroom
            state: "on"
        actions:
          - action: light.turn_off
            target:
              entity_id: light.bathroom

      - alias: Light kitchen on when sensor on
        triggers:
          - trigger: state
            entity_id: binary_sensor.649e314c943b_occupancy
            from: "off"
            to: "on"
        conditions:
          - condition: state
            entity_id: light.kitchen
            state: "off"
          - condition: numeric_state
            entity_id: sensor.649e314c943b_illuminance
            below: 1500
        actions:
          - action: light.turn_on
            target:
              entity_id: light.kitchen

      - alias: Light kitchen off when sensor off
        triggers:
          - trigger: state
            entity_id: binary_sensor.649e314c943b_occupancy
            from: "on"
            to: "off"
        conditions:
          - condition: state
            entity_id: light.kitchen
            state: "on"
        actions:
          - action: light.turn_off
            target:
              entity_id: light.kitchen
    '';
  };
}
