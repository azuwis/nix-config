{ config, lib, pkgs, ... }:

let
  component = pkgs.fetchFromGitHub rec {
    name = "${owner}-${repo}-${rev}";
    owner = "AlexxIT";
    repo = "XiaomiGateway3";
    rev = "9bf168671a3f946c331eeacf1046aee96ccb3084";
    sha256 = "sha256-QwsUmtB+n7Vp779kE0vL++xhmySHuLD1sbczyxa1EHc=";
  };
in

{
  hass.file."custom_components/xiaomi_gateway3".source = "${component}/custom_components/xiaomi_gateway3";

  services.home-assistant.extraPackages = ps: with ps; [
    zigpy
  ];

  services.home-assistant.config = {
    # logger.logs."custom_components.xiaomi_gateway3" = "debug";
  };
}
