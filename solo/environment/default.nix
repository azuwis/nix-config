{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.environment;
in

{
  options = {
    environment = {
      pathsToLink = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      systemPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
      };
    };

    solo = {
      path = lib.mkOption { };

      shell = lib.mkOption {
        type = lib.types.path;
      };
    };
  };

  config = {
    environment.pathsToLink = [
      "/bin"
      "/share/man"
    ];

    solo.path = pkgs.buildEnv {
      # nixpkgs/modules/config/system-path.nix
      inherit (cfg) pathsToLink;

      name = "profile-path";

      paths = cfg.systemPackages;
    };

    environment.systemPackages = with pkgs; [
      coreutils-full
    ];
  };
}
