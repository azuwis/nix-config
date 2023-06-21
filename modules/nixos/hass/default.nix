{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkDefault mkEnableOption mkIf;
  cfg = config.my.hass;
in
{
  imports = [
    (lib.mkAliasOptionModule [ "hass" "file" ] [ "home-manager" "users" "hass" "home" "file" ])
    (lib.mkAliasOptionModule [ "hass" "automations" ] [ "home-manager" "users" "hass" "home" "file" "automations.yaml" "text" ])
    ./aligenie.nix
    ./braviatv.nix
    ./device_tracker.nix
    ./light.nix
    ./lovelace.nix
    ./mini-media-player.nix
    ./mqtt.nix
    ./simple-thermostat.nix
    ./smartir.nix
    ./theme.nix
    # ./weather.nix
    ./xiaomi_gateway3.nix
    ./xiaomi_miot.nix
    # ./zhibot.nix
    ./zigbee2mqtt.nix
    ./zigbee2mqtt-networkmap.nix
  ];

  options.my.hass = {
    enable = mkEnableOption (mdDoc "hass");
  };

  config = mkIf cfg.enable {
    # let my.user read data dir
    users.users.hass.homeMode = "0750";
    systemd.services.home-assistant.serviceConfig.UMask = lib.mkForce "0027";
    systemd.tmpfiles.rules = [
      "a+ ${config.services.home-assistant.configDir} - - - - d:u:${config.my.user}:r-x,u:${config.my.user}:r-x"
    ];

    services.home-assistant = {
      enable = true;
      # package = (pkgs.home-assistant.override {
      #   extraComponents = [
      #   ];
      # }).overrideAttrs (o: { doInstallCheck = false; });
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
      sun = { };
      logger.default = "warning";
      automation = "!include automations.yaml";
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

    home-manager.users.hass.home.stateVersion = "22.05";
    home-manager.users.hass.home.file =
      let
        hassConfig = ./config;
        file = builtins.mapAttrs
          (name: value: {
            source = "${hassConfig}/${name}";
          })
          (builtins.readDir hassConfig);
      in
      file;
  };
}
