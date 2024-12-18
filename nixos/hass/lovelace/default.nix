{
  config,
  lib,
  pkgs,
  ...
}:

let
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
                {
                  type = "state-icon";
                  entity = "light.living_room";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "72.8%";
                    left = "75.3%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "light.1660a6874242f000_group";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "72.8%";
                    left = "93%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "climate.gree_climate_9424b8123fe900";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "72.6%";
                    left = "88%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "media_player.sony_kdl_55w800b";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "72.6%";
                    left = "59%";
                  };
                }
                # dining room
                {
                  type = "state-icon";
                  entity = "light.16609ab46d42b000_group";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "43%";
                    left = "63%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "light.yeelink_fancl5_e358_light";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "51.8%";
                    left = "80%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "fan.yeelink_fancl5_e358_fan";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "51.8%";
                    left = "75%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "humidifier.deye_z20_81f8_dehumidifier";
                  style = {
                    top = "42.9%";
                    left = "43.2%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.deye_z20_81f8_relative_humidity";
                  style = {
                    top = "42.2%";
                    left = "52%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.deye_z20_81f8_temperature";
                  style = {
                    top = "44.2%";
                    left = "52.9%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.1775bcf17c0e_humidity";
                  style = {
                    top = "42.2%";
                    left = "79%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.1775bcf17c0e_temperature";
                  style = {
                    top = "44.2%";
                    left = "79.9%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "binary_sensor.649e314c943b_occupancy";
                  style = {
                    top = "50.8%";
                    left = "55%";
                  };
                }
                # primary bedroom
                {
                  type = "state-icon";
                  entity = "light.primary_bedroom";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "72%";
                    left = "31%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "climate.xiaomi_mt0_bedd_air_conditioner";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "84.3%";
                    left = "51.3%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "fan.xiaomi_mt0_bedd_air_fresh";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "80.3%";
                    left = "51.3%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.xiaomi_mt0_bedd_temperature";
                  tap_action = {
                    action = "navigate";
                    navigation_path = "/lovelace/history";
                  };
                  hold_action = {
                    action = "more-info";
                  };
                  style = {
                    top = "83.5%";
                    left = "41%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.xiaomi_mt0_bedd_relative_humidity";
                  tap_action = {
                    action = "navigate";
                    navigation_path = "/lovelace/history";
                  };
                  hold_action = {
                    action = "more-info";
                  };
                  style = {
                    top = "81.5%";
                    left = "40.1%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.xiaomi_mt0_bedd_co2_density";
                  tap_action = {
                    action = "navigate";
                    navigation_path = "/lovelace/history";
                  };
                  hold_action = {
                    action = "more-info";
                  };
                  style = {
                    top = "85.5%";
                    left = "40%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "humidifier.leshow_jsq1_4d84_humidifier";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "75%";
                    left = "50%";
                  };
                }
                {
                  type = "conditional";
                  conditions = [
                    {
                      entity = "humidifier.leshow_jsq1_4d84_humidifier";
                      state_not = "unavailable";
                    }
                  ];
                  elements = [
                    {
                      type = "state-label";
                      entity = "sensor.leshow_jsq1_4d84_water_level";
                      tap_action = {
                        action = "navigate";
                        navigation_path = "/lovelace/history";
                      };
                      hold_action = {
                        action = "more-info";
                      };
                      style = {
                        top = "72.3%";
                        left = "50.6%";
                      };
                    }
                    {
                      type = "state-label";
                      entity = "sensor.leshow_jsq1_4d84_relative_humidity";
                      tap_action = {
                        action = "navigate";
                        navigation_path = "/lovelace/history";
                      };
                      hold_action = {
                        action = "more-info";
                      };
                      style = {
                        top = "70.3%";
                        left = "49%";
                      };
                    }
                  ];
                }
                {
                  type = "state-icon";
                  entity = "cover.lumi_hmcn01_7c8c_curtain";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "89.2%";
                    left = "33.9%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "media_player.edifier_r2000db";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "66%";
                    left = "50%";
                  };
                }
                # secondary bedroom
                {
                  type = "state-icon";
                  entity = "light.secondary_bedroom";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "23%";
                    left = "20.3%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "light.1697cc678402b000_group";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "23%";
                    left = "36.5%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "climate.xiaomi_mt0_cdd0_air_conditioner";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "17.5%";
                    left = "8%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "fan.xiaomi_mt0_cdd0_air_fresh";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "13.5%";
                    left = "8%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.xiaomi_mt0_cdd0_temperature";
                  tap_action = {
                    action = "navigate";
                    navigation_path = "/lovelace/history";
                  };
                  hold_action = {
                    action = "more-info";
                  };
                  style = {
                    top = "16%";
                    left = "19%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.xiaomi_mt0_cdd0_relative_humidity";
                  tap_action = {
                    action = "navigate";
                    navigation_path = "/lovelace/history";
                  };
                  hold_action = {
                    action = "more-info";
                  };
                  style = {
                    top = "14%";
                    left = "18%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.xiaomi_mt0_cdd0_co2_density";
                  tap_action = {
                    action = "navigate";
                    navigation_path = "/lovelace/history";
                  };
                  hold_action = {
                    action = "more-info";
                  };
                  style = {
                    top = "18%";
                    left = "20.3%";
                  };
                }
                # kids room
                {
                  type = "state-icon";
                  entity = "light.kids_room";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "43%";
                    left = "20.3%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "climate.xiaomi_mt0_6e25_air_conditioner";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "52.5%";
                    left = "6%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "fan.xiaomi_mt0_6e25_air_fresh";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "48.5%";
                    left = "6%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.xiaomi_mt0_6e25_temperature";
                  tap_action = {
                    action = "navigate";
                    navigation_path = "/lovelace/history";
                  };
                  hold_action = {
                    action = "more-info";
                  };
                  style = {
                    top = "51.5%";
                    left = "17%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.xiaomi_mt0_6e25_relative_humidity";
                  tap_action = {
                    action = "navigate";
                    navigation_path = "/lovelace/history";
                  };
                  hold_action = {
                    action = "more-info";
                  };
                  style = {
                    top = "49.5%";
                    left = "15.8%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.xiaomi_mt0_6e25_co2_density";
                  tap_action = {
                    action = "navigate";
                    navigation_path = "/lovelace/history";
                  };
                  hold_action = {
                    action = "more-info";
                  };
                  style = {
                    top = "53.5%";
                    left = "18.3%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.a4c138008ef3_humidity";
                  style = {
                    top = "41.9%";
                    left = "7.9%";
                  };
                }
                {
                  type = "state-label";
                  entity = "sensor.kids_room_temperature";
                  style = {
                    top = "43.9%";
                    left = "10%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "cover.lumi_hmcn01_ea01_curtain";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "59%";
                    left = "11.3%";
                  };
                }
                # kitchen
                {
                  type = "state-icon";
                  entity = "light.kitchen";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "16%";
                    left = "71%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "binary_sensor.a4c138694c34_occupancy";
                  style = {
                    top = "9%";
                    left = "71%";
                  };
                }
                # bathroom
                {
                  type = "state-icon";
                  entity = "light.bathroom";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "23%";
                    left = "51%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "binary_sensor.dced8387eef4_occupancy";
                  style = {
                    top = "25.5%";
                    left = "45.5%";
                  };
                }
                {
                  type = "state-icon";
                  entity = "climate.yeelink_v6_af1f_ptc_bath_heater";
                  hold_action = {
                    action = "toggle";
                  };
                  style = {
                    top = "20%";
                    left = "45.5%";
                  };
                  card_mod.style."state-badge $ ha-state-icon" = ''
                    ha-state-icon[data-state="ventilate"] {
                      color: var(--state-climate-cool-color) !important;
                    }
                  '';
                }
                {
                  type = "state-icon";
                  entity = "binary_sensor.0x00158d00028f9af8_contact";
                  style = {
                    top = "14.7%";
                    left = "45.5%";
                    # Reverse on/off color, https://www.home-assistant.io/integrations/frontend/#state-color
                    "--state-binary_sensor-door-on-color" = "var(--state-icon-color)";
                    "--state-binary_sensor-door-off-color" = "var(--amber-color)";
                  };
                }
                {
                  type = "state-label";
                  entity = "climate.yeelink_v6_af1f_ptc_bath_heater";
                  attribute = "current_temperature";
                  suffix = "°C";
                  style = {
                    top = "14.7%";
                    left = "53.5%";
                  };
                }
                # people
                # https://angel-rs.github.io/css-color-filter-generator/
                {
                  type = "image";
                  entity = "device_tracker.az";
                  image = "/local/generated/az.png";
                  state_filter = {
                    not_home = "brightness(0) saturate(100%) invert(44%) sepia(11%) saturate(1915%) hue-rotate(167deg) brightness(93%) contrast(95%)";
                  };
                  style = {
                    top = "89%";
                    left = "4%";
                    width = "5%";
                  };
                }
                {
                  type = "image";
                  entity = "device_tracker.tf";
                  image = "/local/generated/tf.png";
                  state_filter = {
                    not_home = "brightness(0) saturate(100%) invert(44%) sepia(11%) saturate(1915%) hue-rotate(167deg) brightness(93%) contrast(95%)";
                  };
                  style = {
                    top = "92.3%";
                    left = "4%";
                    width = "5%";
                  };
                }
                {
                  type = "image";
                  entity = "device_tracker.yq";
                  image = "/local/generated/yq.png";
                  state_filter = {
                    not_home = "brightness(0) saturate(100%) invert(44%) sepia(11%) saturate(1915%) hue-rotate(167deg) brightness(93%) contrast(95%)";
                  };
                  style = {
                    top = "95.6%";
                    left = "4%";
                    width = "5%";
                  };
                }
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
