{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getHmModules getModules;
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
    (inputs.home-manager.outPath + "/nixos")
    ../common
    ../common/home-manager.nix
    ../common/nixpkgs
    ../common/registry
    ../common/system
  ]
  ++ getModules [ ./. ];

  hm.imports = getHmModules [ ./. ];

  environment.systemPackages = [ pkgs.agenix ];

  # Use information from npins to set system version suffix
  system.nixos.versionSuffix =
    lib.mkIf (inputs.nixpkgs ? revision)
      ".${lib.substring 0 7 inputs.nixpkgs.revision}";
}
