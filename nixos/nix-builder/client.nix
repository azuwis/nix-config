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
  };

  config = mkIf cfg.enable {
    age.secrets.nix-ssh = {
      file = "${inputs.my}/nix-ssh.age";
      mode = "0440";
      group = "wheel";
    };

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

    programs.ssh.extraConfig = ''
      Host builder
        HostName ${inputs.my.builder}
        IdentitiesOnly yes
        IdentityFile /run/agenix/nix-ssh
        Port 22
        User nix-ssh
    '';
  };
}
