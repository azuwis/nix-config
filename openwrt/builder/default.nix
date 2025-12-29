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
      pkgs =
        let
          fetchurl =
            args:
            if builtins.match config.ignoreHashUrlRegex args.url != null then
              # Override pkgs.fetchurl with builtins.fetchurl, remove sha256 arg to let it
              # works in impure mode, another way to workaround hash mismatch problem
              # https://github.com/astro/nix-openwrt-imagebuilder/?tab=readme-ov-file#refreshing-hashes
              builtins.trace "Ignore hash of ${args.url}" (builtins.fetchurl (removeAttrs args [ "sha256" ]))
            else
              pkgs.fetchurl args;
        in
        if
          !(builtins ? currentSystem) # In pure mode
          || config.ignoreHashUrlRegex == ""
        then
          pkgs
        else
          pkgs // { inherit fetchurl; };
      # Dereference files and make them writable
      postConfigure = ''
        cp --recursive --dereference --no-preserve=all files/ files.copy/
        rm -r files
        mv files.copy files
      '';
    };
  };
}
