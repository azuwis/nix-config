let
  inputs = import ../inputs;
  lib = import ../lib;
  pkgs = import ../pkgs {
    # openwrt-imagebuilder runs only in x86_64-linux
    # https://openwrt.org/docs/guide-user/additional-software/imagebuilder
    system = "x86_64-linux";
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
