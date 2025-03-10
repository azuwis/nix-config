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
    "${inputs.agenix.outPath}/modules/age.nix"
    "${inputs.home-manager.outPath}/nixos"
    ../common
  ] ++ inputs.lib.getModules [ ./. ];

  hm.imports = inputs.lib.getHmModules [ ./. ];

  environment.systemPackages = [ pkgs.agenix ];
}
