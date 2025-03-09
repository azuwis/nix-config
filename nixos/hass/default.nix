{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../../lib) getModules;
  inherit (lib) mkDefault mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  imports = [
    (lib.mkAliasOptionModule
      [
        "hass"
        "automations"
      ]
      [
        "environment"
        "etc"
        "home-assistant/automations.yaml"
        "text"
      ]
    )
  ] ++ getModules [ ./. ];

  options.my.hass = {
    enable = mkEnableOption "hass";
  };

  config = mkIf cfg.enable {
    my.hass = {
      # aligenie = true;
      braviatv = true;
      device_tracker = true;
      # gree = true;
      gree2 = true;
      mini-media-player = true;
      simple-thermostat = true;
      smartir = true;
      # weather = true;
      xiaomi_gateway3 = true;
      xiaomi_miot = true;
      # zhibot = true;
      # zigbee2mqtt = true;
      # zigbee2mqtt-networkmap = true;
    };

    # let my.user read data dir
    users.users.hass.homeMode = "0750";
    systemd.services.home-assistant.serviceConfig.UMask = lib.mkForce "0027";
    systemd.tmpfiles.rules = [
      "a+ ${config.services.home-assistant.configDir} - - - - d:u:${config.my.user}:r-x,u:${config.my.user}:r-x"
    ];

    services.home-assistant = {
      enable = true;
      # Override default value [ "default_config" "met" "esphome" ], may cause problem for onboarding
      extraComponents = [ "default_config" ];
      extraPackages = ps: with ps; [ holidays ];
    };

    age.secrets.hass = {
      file = "${inputs.my.outPath}/hass.age";
      path = "${config.services.home-assistant.configDir}/secrets.yaml";
      owner = "hass";
      group = "hass";
    };

    services.home-assistant.config = {
      homeassistant = {
        name = "Home";
        country = "CN";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = "!secret elevation";
        customize_domain.climate.icon = "mdi:air-conditioner";
        packages = "!include_dir_named packages";
      };
      frontend = { };
      config = { };
      http = {
        server_host = "127.0.0.1";
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
      history = { };
      logbook = { };
      mobile_app = { };
      sun = { };
      logger.default = "warning";
      automation = "!include /etc/home-assistant/automations.yaml";
    };

    my.nginx.enable = mkDefault true;
    services.nginx.virtualHosts.hass = {
      serverName = "h.${config.my.domain}";
      onlySSL = true;
      useACMEHost = "default";
      extraConfig = ''
        ssl_client_certificate ${config.my.ca};
        ssl_verify_client on;
      '';
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
        proxyWebsockets = true;
      };
    };
  };
}
