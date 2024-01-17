{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.nix-builder;
in
{
  imports = [
    ./client.nix
  ];

  options.my.nix-builder = {
    enable = mkEnableOption "nix-builder";
  };

  config = mkIf cfg.enable {
    nix.settings.trusted-users = [ "nix-ssh" ];
    nix.sshServe = {
      enable = true;
      write = true;
      keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSWc7PHn11yf+fuveTjzhcQpwgeWavw3YB4FVbj/d9t" ];
      protocol = "ssh-ng";
    };
  };
}
