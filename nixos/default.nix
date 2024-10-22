{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  # Files to backup
  # /var/lib/acme/
  # /var/lib/bluetooth/
  # /var/lib/hass/
  # /var/lib/qbittorrent/
  # /var/lib/torrent-ratio/
  # /var/lib/zigbee2mqtt/
  imports = [
    inputs.agenix.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    ../common
  ] ++ lib.my.getModules [ ./. ];

  hm.imports = lib.my.getHmModules [ ./. ];

  environment.systemPackages = [ pkgs.agenix ];
}
