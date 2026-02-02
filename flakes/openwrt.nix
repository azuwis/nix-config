let
  inputs = import ../inputs { };
  lib = import ../lib;
  pkgs = import ../pkgs { };

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
