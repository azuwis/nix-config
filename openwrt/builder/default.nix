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
        buildInputs = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
        };

        disabledServices = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        debug = lib.mkEnableOption "debug";

        extraPackages = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          default = { };
        };

        ignoreHashUrlRegex = lib.mkOption {
          type = lib.types.str;
          # default = ''https://downloads\.openwrt\.org/.*/Packages'';
          default = ''https://downloads\.openwrt\.org/.*/packages/.*/(Packages|sha256sums|packages\.adb)'';
        };

        hostname = lib.mkOption {
          type = lib.types.str;
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
                  builtins.trace "Ignore hash of ${args.url}" {
                    inherit (args) name;
                    outPath = builtins.fetchurl (removeAttrs args [ "hash" ]);
                  }
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

        release = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      image = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
      };
    };

  config = {
    image =
      if cfg.pkgs.stdenv.buildPlatform.system != "x86_64-linux" then
        throw "openwrt-imagebuilder runs only in x86_64-linux, see https://openwrt.org/docs/guide-user/additional-software/imagebuilder"
      else
        let
          profiles = import (inputs.nix-openwrt-imagebuilder.outPath + "/profiles.nix") (
            {
              inherit (cfg) pkgs;
            }
            // lib.optionalAttrs (cfg.release != "") {
              inherit (cfg) release;
            }
          );
        in
        (import (inputs.nix-openwrt-imagebuilder.outPath + "/builder.nix") (
          profiles.identifyProfile cfg.profile
          // {
            inherit (cfg)
              disabledServices
              extraPackages
              packages
              pkgs
              ;
            files = config.files.path;
          }
        )).overrideAttrs
          (old: {
            nativeBuildInputs =
              (old.nativeBuildInputs or [ ]) ++ lib.optionals cfg.debug [ pkgs.breakpointHook ];

            buildInputs = (old.buildInputs or [ ]) ++ cfg.buildInputs;

            # Dereference files and make them writable
            postConfigure = (old.postConfigure or "") + ''
              cp --recursive --dereference --no-preserve=all files/ files.copy/
              find -L files/ -type f -executable -printf "%P\0" | xargs -0 -I {} chmod +x "files.copy/{}"
              rm -r files
              mv files.copy files
            '';

            postInstall =
              (old.postInstall or "")
              + ''
                cp -r ./files $out
                find files \( -type d -printf "%M %4s %p/\n" \) -o \( -type f -printf "%M %4s %p\n" \) >$out/files.list
              ''
              + lib.optionalString cfg.debug ''
                exit 1
              '';
          });
  };
}
