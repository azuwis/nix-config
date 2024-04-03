{
  config,
  lib,
  pkgs,
  ...
}:

let
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
    ./aligenie.nix
    ./braviatv.nix
    ./device_tracker.nix
    ./gree.nix
    # ./gree2.nix
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
    enable = mkEnableOption "hass";
  };

  config = mkIf cfg.enable {
    # let my.user read data dir
    users.users.hass.homeMode = "0750";
    systemd.services.home-assistant.serviceConfig.UMask = lib.mkForce "0027";
    systemd.tmpfiles.rules = [
      "a+ ${config.services.home-assistant.configDir} - - - - d:u:${config.my.user}:r-x,u:${config.my.user}:r-x"
    ];

    systemd.services.home-assistant.preStart = ''
      cp --no-preserve=mode /etc/home-assistant/automations.yaml ${config.services.home-assistant.configDir}/automations.yaml
      ln -fns ${./config/packages} ${config.services.home-assistant.configDir}/packages
    '';

    services.home-assistant = {
      enable = true;
      extraPackages = ps: with ps; [
        holidays
      ];
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
  };
}
