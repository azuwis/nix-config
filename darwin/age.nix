{ config, lib, pkgs, ... }:

{
  # https://github.com/LnL7/nix-darwin/pull/381
  age.sshKeyPaths = [ "/etc/age/keys.txt" ];
  age.secrets.wg0 = {
    file = "/etc/age/wg0.age";
    path = "/etc/wireguard/wg0.conf";
  };
}
