{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.services.nix-builder;
in
{
  imports = [ ./client.nix ];

  options.services.nix-builder = {
    enable = mkEnableOption "nix-builder";
  };

  config = mkIf cfg.enable {
    age.secrets.nix-secret-key.file = "${inputs.my.outPath}/nix-secret-key.age";

    nix.settings = {
      keep-outputs = true;
      secret-key-files = [ config.age.secrets.nix-secret-key.path ];
      # nix-ssh only needs daemon access (allowed-users), not privileged operations (trusted-users).
      # trusted-users would be needed if nix-ssh were to: set substituters, import unsigned NARs,
      # or override privileged nix.conf options (e.g. --option extra-sandbox-paths).
      # trusted-users implies allowed-users; using allowed-users explicitly is more precise.
      # trusted-users = [ "nix-ssh" ];
      allowed-users = [ "nix-ssh" ];
    };

    nix.sshServe = {
      enable = true;
      write = true;
      keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBSWc7PHn11yf+fuveTjzhcQpwgeWavw3YB4FVbj/d9t" ];
      protocol = "ssh-ng";
    };
  };
}
