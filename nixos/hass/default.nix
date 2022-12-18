{ config, lib, pkgs, ... }:

let
  inherit (config.my) domain;
in

{
  imports = [
    ./acpartner.nix
    ./braviatv.nix
    ./light.nix
    ./lovelace.nix
    ./mini-media-player.nix
    ./mqtt.nix
    ./theme.nix
    ./weather.nix
    ./xiaomi_miot.nix
    ./zhibot.nix
    ./zigbee2mqtt.nix
    ./zigbee2mqtt-networkmap.nix
  ];

  # let my.user read data dir
  systemd.services.home-assistant.serviceConfig.UMask = lib.mkForce "0027";
  users.users.${config.my.user}.extraGroups = [ "hass" ];
  users.users.hass.homeMode = "0750";

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
      latitude = "!secret latitude";
      longitude = "!secret longitude";
      elevation = "!secret elevation";
      customize_domain.climate.icon = "mdi:air-conditioner";
      packages = "!include_dir_named packages";
    };
    frontend = {};
    config = {};
    http = {
      server_host = "127.0.0.1";
      use_x_forwarded_for = true;
      trusted_proxies = [ "127.0.0.1" ];
    };
    history = {};
    logbook = {};
    sun = {};
    logger.default = "warning";
  };

  services.nginx.virtualHosts.hass = {
    serverName = "h.${domain}";
    onlySSL = true;
    useACMEHost = "default";
    extraConfig = ''
      ssl_client_certificate ${../ca.crt};
      ssl_verify_client on;
    '';
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
  };

  home-manager.users.hass.home.stateVersion = "22.05";
  home-manager.users.hass.home.file = let
    hassConfig = ./config;
    file = builtins.mapAttrs
    (name: value: {
      source = "${hassConfig}/${name}";
    })
    (builtins.readDir hassConfig);
  in file;
}
