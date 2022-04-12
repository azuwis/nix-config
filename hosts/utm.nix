{ config, lib, pkgs, ... }:

{
  imports = [
    # nixos-generate-config --show-hardware-config > hardware-utm.nix
    ./hardware-utm.nix
  ];
  fileSystems."/".options = [ "compress-force=zstd" ];
  networking.hostName = "utm";
  # The iface name on UTM is not stable, use en* to match it
  systemd.network.networks."99-en-dhcp" = {
    matchConfig.Name = [ "en*" ];
    DHCP = "yes";
  };
}
