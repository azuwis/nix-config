{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf mkMerge;
  cfg = config.environment;
in

{
  options = {
    environment = {
      path = lib.mkOption { };

      pathsToLink = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      shell = lib.mkOption {
        type = lib.types.path;
      };

      systemPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
      };
    };
  };

  config = mkMerge [
    {
      environment.pathsToLink = [
        "/bin"
        "/share/man"
      ];

      environment.path = pkgs.buildEnv {
        # nixpkgs/modules/config/system-path.nix
        inherit (cfg) pathsToLink;

        name = "profile-path";

        paths = cfg.systemPackages;
      };
    }

    (mkIf config.programs.git.enable {
      environment.variables.GIT_CONFIG_GLOBAL = config.environment.etc.gitconfig.source;
    })
  ];
}
