{ config, lib, pkgs, ...}:

let
 inherit (config.my) domain;
in

{
  imports = [
    ./mosquitto.nix
    ./zigbee2mqtt.nix
  ];
}
