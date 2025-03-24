{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.nix-builder;
  inputs = import ../../inputs;
in
{
  imports = [ ./client.nix ];

  options.my.nix-builder = {
    enable = mkEnableOption "nix-builder";
  };

  config = mkIf cfg.enable {
    age.secrets.nix-secret-key.file = inputs.my.outPath + "/nix-secret-key.age";

    nix.settings = {
      secret-key-files = [ config.age.secrets.nix-secret-key.path ];
      trusted-users = [ "nix-ssh" ];
    };

    nix.sshServe = {
      enable = true;
      write = true;
      keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSWc7PHn11yf+fuveTjzhcQpwgeWavw3YB4FVbj/d9t" ];
      protocol = "ssh-ng";
    };
  };
}
