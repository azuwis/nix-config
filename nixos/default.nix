{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
  # To use `inputs` in `imports`, normally `specialArgs` is used when calling
  # nixpkgs/nixos/lib/eval-config.nix, but to be compatible with non-flake usage
  # of nixos-rebuild/darwin-rebuild/nix-on-droid, `import ../inputs` is much
  # simpler solution
  inputs = import ../inputs;
in

{
  # Files to backup
  # /var/lib/acme/
  # /var/lib/bluetooth/
  # /var/lib/hass/
  # /var/lib/qbittorrent/
  # /var/lib/torrent-ratio/
  # /var/lib/zigbee2mqtt/
  imports = [
    (inputs.agenix.outPath + "/modules/age.nix")
    (inputs.disko.outPath + "/module.nix")
    ../common
    ../desktop
  ]
  ++ getModules [ ./. ];

  environment.systemPackages = [ pkgs.agenix ];

  registry.entries = [ "disko" ];

  # Use information from inputs to set system version suffix
  system.nixos.versionSuffix = lib.mkIf (
    inputs.nixpkgs ? lastModifiedDate && inputs.nixpkgs ? shortRev
  ) ".${lib.substring 0 8 inputs.nixpkgs.lastModifiedDate}.${inputs.nixpkgs.shortRev}";
}
