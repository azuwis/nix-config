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

  config = {
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

    environment.systemPackages = with pkgs; [
      coreutils-full
    ];
  };
}
