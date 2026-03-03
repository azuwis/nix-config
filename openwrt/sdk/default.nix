{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.sdk;
  inherit (config.image.config) release target variant;
in

{
  options.sdk = {
    enable = lib.mkEnableOption "sdk";

    builds = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            downloadHash = lib.mkOption {
              type = lib.types.str;
            };

            packages = lib.mkOption {
              type = lib.types.listOf lib.types.str;
            };
          };
        }
      );
      default = [ ];
    };

    feeds = lib.mkOption {
      type = lib.types.attrsOf lib.types.package;
    };

    outputs = lib.mkOption {
      readOnly = true;
      type = lib.types.listOf lib.types.package;
    };

    src = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fetchurl {
        url =
          let
            libc = if builtins.elem target [ "ipq806x" ] then "musl_eabi" else "musl";
          in
          "https://downloads.openwrt.org/releases/${release}/targets/${target}/${variant}/openwrt-sdk-${release}-${target}-${variant}_gcc-13.3.0_${libc}.Linux-x86_64.tar.zst";
        hash =
          {
            ipq806x.generic = "sha256-cD8CY5a0SbrrHSNMxJv7dQHOz99FQJ+huT1HcfpOkHQ=";
            ramips.mt7621 = "sha256-8BqooKQ1VnpR74xhc/j+oh8DTWn8eZXKDQDlk+rK8nk=";
          }
          .${target}.${variant};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    builder.buildInputs = cfg.outputs;
    builder.extraPackages =
      let
        packages2nix = pkgs.callPackage (inputs.nix-openwrt-imagebuilder.outPath + "/packages2nix.nix") { };
        callPackages2nix =
          {
            mode,
            packages,
            sha256sums,
            prefix,
          }:
          let
            drv = pkgs.runCommand "${packages.name}-ifd" { } ''
              if [ "$(cat ${packages} | wc -l)" -gt 1 ]; then
                ${packages2nix}/bin/packages2nix ${mode} ${packages} ${sha256sums} ${prefix} > $out
              else
                echo '{}' > $out
              fi
            '';
          in
          import drv;
        feed2nix =
          output: feed:
          lib.mapAttrs
            (
              name: value:
              value
              // {
                type = "real";
                file = "${output}/${feed}/${value.filename}";
              }
            )
            (callPackages2nix {
              mode = if lib.versionAtLeast release "25" then "apk" else "opkg";
              packages = {
                name = feed;
                outPath = "${output}/${feed}/Packages";
              };
              sha256sums = "";
              prefix = "";
            });
      in
      lib.mergeAttrsList (
        builtins.concatMap (output: map (feed2nix output) (builtins.attrNames cfg.feeds)) cfg.outputs
      );

    sdk.feeds = {
      azuwis = pkgs.fetchFromGitHub {
        owner = "azuwis";
        repo = "openwrt-azuwis";
        rev = "cfd8f8991d9e95bfeeb893417e0bdffaa27e3dd1";
        hash = "sha256-4HIQLDz9F2aQkmFcwk2rUJtDe4617BqGwS0Z9iP2xjQ=";
      };
      base = pkgs.fetchFromGitHub {
        owner = "openwrt";
        repo = "openwrt";
        tag = "v${release}";
        hash = "sha256-gtrbBmR0dM6j+KKLd0Zv/x2cqeEs/jHtptlM1v4Kvaw=";
      };
      packages = pkgs.fetchFromGitHub {
        owner = "openwrt";
        repo = "packages";
        rev = "953b6d47b4e9f0ad3c39547c6d3f9a828f10e206";
        hash = "sha256-tae7UKBydzLmszomkjRUqNKGDQbWJLcJPmDdc3z5fLg=";
      };
    };

    sdk.outputs = map (
      build:
      pkgs.callPackage ./package.nix {
        inherit (build) downloadHash packages;
        inherit (cfg) feeds src;
      }
    ) cfg.builds;
  };
}
