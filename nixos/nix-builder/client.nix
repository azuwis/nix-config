{
  config,
  lib,
  pkgs,
  ...
}:

# /root/.ssh/config
# Host builder
#   HostName <IP>
#   IdentitiesOnly yes
#   IdentityFile ~/.ssh/nix-ssh
#   Port 22
#   User nix-ssh

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.my.nix-builder-client;
in
{
  options.my.nix-builder-client = {
    enable = mkEnableOption "nix-builder-client";
    systems = mkOption {
      type = types.listOf types.str;
      default = [
        "i686-linux"
        "x86_64-linux"
      ];
    };
  };

  config = mkIf cfg.enable {
    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "builder";
          systems = cfg.systems;
          protocol = "ssh-ng";
          maxJobs = 12;
        }
      ];
      settings.builders-use-substitutes = true;
    };
  };
}
