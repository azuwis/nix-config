let
  inputs = import ../inputs { };
  lib = import ../lib;
  pkgs = import ../pkgs {
    # TODO: Remove when nixos 26.05 release
    overlays = [
      (final: prev: {
        apk-tools = final.callPackage ../openwrt/builder/apk-tools.nix { };
      })
    ];
  };

  mkOpenwrt =
    host:
    lib.evalModules {
      class = "openwrt";
      modules = [
        { _module.args = { inherit inputs pkgs; }; }
        (../hosts + "/${host}.nix")
      ];
    };
in

lib.genAttrs [
  "wg3526"
  "xr500"
] mkOpenwrt
