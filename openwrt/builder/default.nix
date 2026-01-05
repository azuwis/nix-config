{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.builder;
in

{
  options =
    import ../../lib/linkdir.nix {
      inherit config lib pkgs;
      optionName = "files";
    }
    // {
      builder = {
        disabledServices = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        debug = lib.mkEnableOption "debug";

        ignoreHashUrlRegex = lib.mkOption {
          type = lib.types.str;
          # default = "https://downloads\.openwrt\.org/.*/Packages";
          default = "https://downloads\.openwrt\.org/.*/packages/.*/Packages";
        };

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        pkgs = lib.mkOption {
          type = lib.types.pkgs;
          default =
            let
              fetchurl =
                args:
                if builtins.match cfg.ignoreHashUrlRegex args.url != null then
                  # Override pkgs.fetchurl with builtins.fetchurl, remove sha256 arg to let it
                  # works in impure mode, another way to workaround hash mismatch problem
                  # https://github.com/astro/nix-openwrt-imagebuilder/?tab=readme-ov-file#refreshing-hashes
                  builtins.trace "Ignore hash of ${args.url}" (builtins.fetchurl (removeAttrs args [ "sha256" ]))
                else
                  pkgs.fetchurl args;
            in
            if
              !(builtins ? currentSystem) # In pure mode
              || cfg.ignoreHashUrlRegex == ""
            then
              pkgs
            else
              pkgs // { inherit fetchurl; };
        };

        profile = lib.mkOption {
          type = lib.types.str;
        };
      };

      image = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
      };
    };

  config = {
    image =
      let
        profiles = import (inputs.nix-openwrt-imagebuilder.outPath + "/profiles.nix") {
          inherit (cfg) pkgs;
        };
      in
      (import (inputs.nix-openwrt-imagebuilder.outPath + "/builder.nix") (
        profiles.identifyProfile cfg.profile
        // {
          inherit (cfg) disabledServices packages;
          files = config.files.path;
          # Dereference files and make them writable
          postConfigure = ''
            cp --recursive --dereference --no-preserve=all files/ files.copy/
            rm -r files
            mv files.copy files
          '';
          postInstall = ''
            cp -r ./files $out
            find files \( -type d -printf "%M %4s %p/\n" \) -o \( -type f -printf "%M %4s %p\n" \) >$out/files.list
          '';
        }
      )).overrideAttrs
        (
          old:
          lib.optionalAttrs cfg.debug {
            nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.breakpointHook ];
            postInstall = old.postInstall + ''
              exit 1
            '';
          }
        );
  };
}
