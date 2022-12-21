{ config, lib, pkgs, ... }:

let
  component = pkgs.fetchFromGitHub rec {
    name = "${repo}-${rev}";
    owner = "syssi";
    repo = "xiaomi_airconditioningcompanion";
    rev = "2022.3.3.0";
    sha256 = "099nmhlw7qz9vllqrq547rzv7ls8qbxiaksj8xxl33fvpyllmrq9";
  };
in

{
  hass.file."custom_components/xiaomi_miio_airconditioningcompanion".source = "${component}/custom_components/xiaomi_miio_airconditioningcompanion";

  services.home-assistant.extraPackages = python3Packages: with python3Packages; [ python-miio ];

  services.home-assistant.config = {
    climate = [{
      platform = "xiaomi_miio_airconditioningcompanion";
      name = "AC partner";
      host = "acpartner.lan";
      token = "!secret ac_partner_token";
      target_sensor = "sensor.ht_bedroom_temperature";
    }];
  };
}
