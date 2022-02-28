{ config, lib, pkgs, ... }:

{
  # wg-quick up wg0
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
  age.secrets.wg0 = {
    file = "/etc/age/wg0.age";
    path = "/etc/wireguard/wg0.conf";
  };
}
