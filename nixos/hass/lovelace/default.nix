{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) recursiveUpdate;
  inherit (pkgs.home-assistant-custom-lovelace-modules) card-mod;

  font = pkgs.fetchurl {
    url = "https://github.com/google/fonts/raw/refs/heads/main/ofl/fascinateinline/FascinateInline-Regular.ttf";
    hash = "sha256-QTEBgQ/kIFIBIogEBNH46JImnmpq+i4A6YD2XvYy7js=";
  };

  generated = pkgs.runCommand "lovelace-generated" { } ''
    mkdir $out
    for i in az tf yq; do
      ${pkgs.imagemagick}/bin/magick -background transparent -fill "#ff9800" -font ${font} -size 128x128 -gravity center label:"''${i^^}" "$out/$i.png"
    done
    ln -fns ${card-mod}/${card-mod.entrypoint} $out/
  '';

  static = ./static;

  state =
    entity: left: top:
    let
      isBinarySensor = lib.hasPrefix "binary_sensor." entity;
      isSensor = lib.hasPrefix "sensor." entity;
    in
    {
      inherit entity;
      style = {
        left = "${left}%";
        top = "${top}%";
      };
      type = if isSensor then "state-label" else "state-icon";
    }
    // lib.optionalAttrs (!isSensor && !isBinarySensor) {
      hold_action = {
        action = "toggle";
      };
    };

  people = id: top: {
    type = "image";
    entity = "device_tracker.${id}";
    image = "/local/generated/${id}.png";
    # https://angel-rs.github.io/css-color-filter-generator/
    state_filter = {
      not_home = "brightness(0) saturate(100%) invert(44%) sepia(11%) saturate(1915%) hue-rotate(167deg) brightness(93%) contrast(95%)";
    };
    style = {
      left = "4%";
      top = "${top}%";
      width = "5%";
    };
  };
in

{
  config = lib.mkIf config.my.hass.enable {
    systemd.services.home-assistant.preStart = ''
      ln -fns ${static} ${config.services.home-assistant.configDir}/www/static
      ln -fns ${generated} ${config.services.home-assistant.configDir}/www/generated
    '';

    services.home-assistant.config.frontend.extra_module_url = [
      "/local/generated/${card-mod.entrypoint}?${card-mod.version}"
    ];

    services.home-assistant.config.lovelace.mode = "yaml";

    # services.home-assistant.customLovelaceModules conflict with services.home-assistant.config.lovelace.resources
    # as of github:NixOS/nixpkgs/2873a73123077953f3e6f34964466018876d87c4
    # services.home-assistant.config.lovelace.resources =
    #   let
    #     mkModule =
    #       name:
    #       let
    #         hash = builtins.hashFile "md5" "${./static}/${name}.js";
    #       in
    #       {
    #         url = "/local/static/${name}.js?v=${hash}";
    #         type = "module";
    #       };
    #   in
    #   [
    #     # (mkModule "glance-card")
    #     # (mkModule "state-icon")
    #   ];

    services.home-assistant.lovelaceConfigWritable = true;
    services.home-assistant.lovelaceConfig = {
      title = "Home";
      views = [
        {
          title = "Home";
          path = "home";
          icon = "mdi:view-grid";
          cards = [
            {
              type = "picture-elements";
              image = "/local/static/floorplan.png?v=3";
              elements = [
                # living room
                (state "light.living_room" "75.3" "72.8")
                (state "light.1660a6874242f000_group" "93" "72.8")
                (state "climate.gree_climate_9424b8123fe900" "88" "72.6")
                (state "media_player.sony_kdl_55w800b" "59" "72.6")
                # dining room
                (state "light.16609ab46d42b000_group" "63" "43")
                (state "light.yeelink_fancl5_e358_light" "80" "51.8")
                (state "fan.yeelink_fancl5_e358_fan" "75" "51.8")
                (state "humidifier.deye_z20_81f8_dehumidifier" "43.2" "42.9")
                (state "sensor.deye_z20_81f8_relative_humidity" "52" "42.2")
                (state "sensor.deye_z20_81f8_temperature" "52.9" "44.2")
                (state "sensor.1775bcf17c0e_humidity" "79" "42.2")
                (state "sensor.1775bcf17c0e_temperature" "79.9" "44.2")
                (state "binary_sensor.649e314c943b_occupancy" "55" "50.8")
                # primary bedroom
                (state "light.primary_bedroom" "31" "72")
                (state "climate.xiaomi_mt0_bedd_air_conditioner" "51.3" "84.3")
                (state "fan.xiaomi_mt0_bedd_air_fresh" "51.3" "80.3")
                (state "sensor.xiaomi_mt0_bedd_temperature" "41" "83.5")
                (state "sensor.xiaomi_mt0_bedd_relative_humidity" "40.1" "81.5")
                (state "sensor.xiaomi_mt0_bedd_co2_density" "40" "85.5")
                (state "humidifier.leshow_jsq1_4d84_humidifier" "50" "75")
                {
                  type = "conditional";
                  conditions = [
                    {
                      entity = "humidifier.leshow_jsq1_4d84_humidifier";
                      state_not = "unavailable";
                    }
                  ];
                  elements = [
                    (state "sensor.leshow_jsq1_4d84_water_level" "50.6" "72.3")
                    (state "sensor.leshow_jsq1_4d84_relative_humidity" "49" "70.3")
                  ];
                }
                (state "cover.lumi_hmcn01_7c8c_curtain" "33.9" "89.2")
                (state "media_player.edifier_r2000db" "50" "66")
                # secondary bedroom
                (state "light.secondary_bedroom" "20.3" "23")
                (state "light.1697cc678402b000_group" "36.5" "23")
                (state "climate.xiaomi_mt0_cdd0_air_conditioner" "8" "17.5")
                (state "fan.xiaomi_mt0_cdd0_air_fresh" "8" "13.5")
                (state "sensor.xiaomi_mt0_cdd0_temperature" "19" "16")
                (state "sensor.xiaomi_mt0_cdd0_relative_humidity" "18" "14")
                (state "sensor.xiaomi_mt0_cdd0_co2_density" "20.3" "18")
                # kids room
                (state "light.kids_room" "20.3" "43")
                (state "climate.xiaomi_mt0_6e25_air_conditioner" "6" "52.5")
                (state "fan.xiaomi_mt0_6e25_air_fresh" "6" "48.5")
                (state "sensor.xiaomi_mt0_6e25_temperature" "17" "51.5")
                (state "sensor.xiaomi_mt0_6e25_relative_humidity" "15.8" "49.5")
                (state "sensor.xiaomi_mt0_6e25_co2_density" "18.3" "53.5")
                (state "sensor.a4c138008ef3_humidity" "7.9" "41.9")
                (state "sensor.kids_room_temperature" "10" "43.9")
                (state "cover.lumi_hmcn01_ea01_curtain" "11.3" "59")
                # kitchen
                (state "light.kitchen" "71" "16")
                (state "binary_sensor.a4c138694c34_occupancy" "71" "9")
                # bathroom
                (state "light.bathroom" "51" "23")
                (state "binary_sensor.dced8387eef4_occupancy" "45.5" "25.5")
                (recursiveUpdate (state "climate.yeelink_v6_af1f_ptc_bath_heater" "45.5" "20") {
                  card_mod.style."state-badge $ ha-state-icon" = ''
                    ha-state-icon[data-state="ventilate"] {
                      color: var(--state-climate-cool-color) !important;
                    }
                  '';
                })
                (recursiveUpdate (state "binary_sensor.0x00158d00028f9af8_contact" "45.5" "14.7") {
                  # Reverse on/off color, https://www.home-assistant.io/integrations/frontend/#state-color
                  style = {
                    "--state-binary_sensor-door-on-color" = "var(--state-icon-color)";
                    "--state-binary_sensor-door-off-color" = "var(--amber-color)";
                  };
                })
                (recursiveUpdate (state "climate.yeelink_v6_af1f_ptc_bath_heater" "53.5" "14.7") {
                  type = "state-label";
                  attribute = "current_temperature";
                  suffix = "°C";
                })
                # people
                (people "az" "89")
                (people "tf" "92.3")
                (people "yq" "95.6")
              ];
            }
            {
              type = "conditional";
              conditions = [
                {
                  entity = "media_player.edifier_r2000db";
                  state = "on";
                }
              ];
              card = {
                type = "custom:mini-media-player";
                entity = "media_player.edifier_r2000db";
                volume_stateless = true;
                hide = {
                  play_pause = true;
                };
              };
            }
            {
              type = "conditional";
              conditions = [
                {
                  entity = "media_player.sony_kdl_55w800b";
                  state = "on";
                }
              ];
              card = {
                type = "custom:mini-media-player";
                entity = "media_player.sony_kdl_55w800b";
                hide_controls = "yes";
                power_color = "yes";
                show_source = "small";
              };
            }
            {
              type = "conditional";
              conditions = [
                {
                  entity = "climate.yeelink_v6_af1f_ptc_bath_heater";
                  state_not = "off";
                }
                {
                  entity = "climate.yeelink_v6_af1f_ptc_bath_heater";
                  state_not = "unavailable";
                }
              ];
              card = {
                type = "custom:simple-thermostat";
                entity = "climate.yeelink_v6_af1f_ptc_bath_heater";
                hide.state = true;
                layout.mode.headings = false;
                sensors = [
                  {
                    entity = "climate.yeelink_v6_af1f_ptc_bath_heater";
                    name = "State";
                  }
                  {
                    entity = "climate.yeelink_v6_af1f_ptc_bath_heater";
                    name = "Fan";
                    attribute = "fan_mode";
                  }
                  {
                    entity = "climate.yeelink_v6_af1f_ptc_bath_heater";
                    name = "Fan level";
                    attribute = "ptc_bath_heater.fan_level";
                  }
                ];
              };
            }
            {
              type = "conditional";
              conditions = [
                {
                  entity = "climate.gree_climate_9424b8123fe900";
                  state_not = "off";
                }
                {
                  entity = "climate.gree_climate_9424b8123fe900";
                  state_not = "unavailable";
                }
              ];
              card = {
                type = "custom:simple-thermostat";
                entity = "climate.gree_climate_9424b8123fe900";
                control = [ "hvac" ];
                layout = {
                  mode = {
                    headings = false;
                  };
                };
                sensors = [
                  {
                    entity = "sensor.1775bcf17c0e_humidity";
                    name = "Humidity";
                  }
                  {
                    entity = "climate.gree_climate_9424b8123fe900";
                    name = "Fan";
                    attribute = "fan_mode";
                  }
                ];
              };
            }
            {
              type = "conditional";
              conditions = [
                {
                  entity = "climate.xiaomi_mt0_bedd_air_conditioner";
                  state_not = "off";
                }
                {
                  entity = "climate.xiaomi_mt0_bedd_air_conditioner";
                  state_not = "unavailable";
                }
              ];
              card = {
                type = "custom:simple-thermostat";
                entity = "climate.xiaomi_mt0_bedd_air_conditioner";
                layout = {
                  mode = {
                    headings = false;
                  };
                };
                sensors = [
                  {
                    entity = "sensor.xiaomi_mt0_bedd_relative_humidity";
                    name = "Humidity";
                  }
                  {
                    entity = "sensor.xiaomi_mt0_bedd_co2_density";
                    name = "Co2";
                  }
                  {
                    entity = "climate.xiaomi_mt0_bedd_air_conditioner";
                    name = "Fan";
                    attribute = "fan_mode";
                  }
                ];
              };
            }
            {
              type = "conditional";
              conditions = [
                {
                  entity = "climate.xiaomi_mt0_cdd0_air_conditioner";
                  state_not = "off";
                }
                {
                  entity = "climate.xiaomi_mt0_cdd0_air_conditioner";
                  state_not = "unavailable";
                }
              ];
              card = {
                type = "custom:simple-thermostat";
                entity = "climate.xiaomi_mt0_cdd0_air_conditioner";
                layout = {
                  mode = {
                    headings = false;
                  };
                };
                sensors = [
                  {
                    entity = "sensor.xiaomi_mt0_cdd0_relative_humidity";
                    name = "Humidity";
                  }
                  {
                    entity = "sensor.xiaomi_mt0_cdd0_co2_density";
                    name = "Co2";
                  }
                  {
                    entity = "climate.xiaomi_mt0_cdd0_air_conditioner";
                    name = "Fan";
                    attribute = "fan_mode";
                  }
                ];
              };
            }
            {
              type = "conditional";
              conditions = [
                {
                  entity = "climate.xiaomi_mt0_6e25_air_conditioner";
                  state_not = "off";
                }
                {
                  entity = "climate.xiaomi_mt0_6e25_air_conditioner";
                  state_not = "unavailable";
                }
              ];
              card = {
                type = "custom:simple-thermostat";
                entity = "climate.xiaomi_mt0_6e25_air_conditioner";
                layout = {
                  mode = {
                    headings = false;
                  };
                };
                sensors = [
                  {
                    entity = "sensor.xiaomi_mt0_6e25_relative_humidity";
                    name = "Humidity";
                  }
                  {
                    entity = "sensor.xiaomi_mt0_6e25_co2_density";
                    name = "Co2";
                  }
                  {
                    entity = "climate.xiaomi_mt0_6e25_air_conditioner";
                    name = "Fan";
                    attribute = "fan_mode";
                  }
                ];
              };
            }
          ];
        }
        {
          title = "History";
          path = "history";
          icon = "mdi:chart-line";
          panel = "yes";
          cards = [
            {
              type = "history-graph";
              refresh_interval = 60;
              entities = [
                {
                  entity = "sensor.xiaomi_mt0_bedd_temperature";
                  name = "Primary";
                }
                {
                  entity = "sensor.xiaomi_mt0_bedd_relative_humidity";
                  name = "Primary";
                }
                {
                  entity = "sensor.xiaomi_mt0_bedd_co2_density";
                  name = "Primary";
                }
                {
                  entity = "sensor.xiaomi_mt0_cdd0_temperature";
                  name = "Secondary";
                }
                {
                  entity = "sensor.xiaomi_mt0_cdd0_relative_humidity";
                  name = "Secondary";
                }
                {
                  entity = "sensor.xiaomi_mt0_cdd0_co2_density";
                  name = "Secondary";
                }
                {
                  entity = "sensor.xiaomi_mt0_6e25_temperature";
                  name = "Kids";
                }
                {
                  entity = "sensor.xiaomi_mt0_6e25_relative_humidity";
                  name = "Kids";
                }
                {
                  entity = "sensor.xiaomi_mt0_6e25_co2_density";
                  name = "Kids";
                }
              ];
            }
          ];
        }
        {
          title = "Map";
          path = "map";
          icon = "mdi:map";
          panel = "yes";
          cards = [
            {
              type = "map";
              entities = [
                "device_tracker.az"
                "device_tracker.tf"
                "zone.home"
                "zone.work"
              ];
              hours_to_show = 24;
            }
          ];
        }
        {
          title = "Settings";
          path = "settings";
          icon = "mdi:cog";
          cards = [
            {
              type = "entities";
              entities = [
                {
                  type = "call-service";
                  name = "Hass reload automations";
                  icon = "mdi:home-assistant";
                  action_name = "Autos";
                  service = "automation.reload";
                  service_data = { };
                }
                {
                  type = "call-service";
                  name = "Hass reload core";
                  icon = "mdi:home-assistant";
                  action_name = "Core";
                  service = "homeassistant.reload_core_config";
                  service_data = { };
                }
                {
                  type = "call-service";
                  name = "Hass reload groups";
                  icon = "mdi:home-assistant";
                  action_name = "Groups";
                  service = "group.reload";
                  service_data = { };
                }
                {
                  type = "call-service";
                  name = "Hass reload scripts";
                  icon = "mdi:home-assistant";
                  action_name = "Scripts";
                  service = "script.reload";
                  service_data = { };
                }
                {
                  type = "call-service";
                  name = "Hass restart";
                  icon = "mdi:home-assistant";
                  action_name = "Restart";
                  service = "homeassistant.restart";
                  service_data = { };
                }
                {
                  type = "call-service";
                  name = "Test notification";
                  icon = "mdi:message-text";
                  action_name = "Test";
                  service = "notify.html5";
                  service_data = {
                    message = "This is a test message";
                  };
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
