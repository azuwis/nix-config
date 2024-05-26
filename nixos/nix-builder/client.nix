{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

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
    supportedFeatures = mkOption {
      type = types.listOf types.str;
      default = [ "big-parallel" ];
    };
  };

  config = mkIf cfg.enable {
    age.secrets = {
      nix-ssh = {
        file = "${inputs.my}/nix-ssh.age";
        mode = "0440";
        group = "wheel";
      };
      nix-ssh-root = {
        file = "${inputs.my}/nix-ssh.age";
      };
    };

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          inherit (cfg) systems supportedFeatures;
          hostName = "builder";
          protocol = "ssh-ng";
          maxJobs = 12;
        }
      ];
      settings = {
        builders-use-substitutes = true;
        substituters = [ "ssh-ng://builder" ];
        trusted-public-keys = [ "builder:FgfOazPpnj8isRyReiBcix6ThpZO8SPo+PrWAKinN48=" ];
      };
    };

    programs.ssh.extraConfig = ''
      Match originalhost builder localuser root
        IdentityFile /run/agenix/nix-ssh-root

      Host builder
        HostName ${config.my.builder}
        IdentitiesOnly yes
        IdentityFile /run/agenix/nix-ssh
        Port 22
        User nix-ssh
    '';
  };
}
