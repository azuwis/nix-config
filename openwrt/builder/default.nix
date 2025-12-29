{
  config,
  lib,
  pkgs,
  ...
}:

{
  options =
    import ../../lib/linkdir.nix {
      inherit config lib pkgs;
      name = "files";
    }
    // {
      builder = lib.mkOption { };

      disabledServices = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      ignoreHashUrlRegex = lib.mkOption {
        type = lib.types.str;
        # default = "https://downloads\.openwrt\.org/.*/[a-z]+/Packages";
        default = "";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      profile = lib.mkOption {
        type = lib.types.str;
      };
    };

  config = {
    builder = {
      disabledServices = config.disabledServices;
      files = config.files.path;
      packages = config.packages;
    };
  };
}
