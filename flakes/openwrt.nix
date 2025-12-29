let
  inputs = import ../inputs;
  lib = import ../lib;
  pkgs = import ../pkgs {
    # openwrt-imagebuilder runs only in x86_64-linux
    # https://openwrt.org/docs/guide-user/additional-software/imagebuilder
    system = "x86_64-linux";
  };

  openwrt-imagebuilder = inputs.nix-openwrt-imagebuilder.outPath;

  mkOpenwrt =
    host:
    let
      config =
        (lib.evalModules {
          modules = [
            { _module.args = { inherit pkgs; }; }
            (../hosts + "/${host}.nix")
          ];
        }).config;
      profiles = import (openwrt-imagebuilder + "/profiles.nix") {
        inherit (config.builder) pkgs;
      };
    in
    import (openwrt-imagebuilder + "/builder.nix") (
      profiles.identifyProfile config.profile // config.builder
    );
  # (import (openwrt-imagebuilder + "/builder.nix") (
  #   profiles.identifyProfile config.profile // config.builder
  # )).overrideAttrs
  #   (old: {
  #     nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.breakpointHook ];
  #     postInstall = old.postInstall + ''
  #       exit 1
  #     '';
  #   });
in

lib.genAttrs [
  "wg3526"
  "xr500"
] mkOpenwrt
