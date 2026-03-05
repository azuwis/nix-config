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

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    builder =
      let
        openwrtPackages = map (package: pkgs.openwrtPackages.${target}.${variant}.${package}) cfg.packages;
      in
      {
        buildInputs = openwrtPackages;
        extraPackages =
          let
            callPackages2nix = pkgs.callPackage (
              inputs.nix-openwrt-imagebuilder.outPath + "/call-packages2nix.nix"
            ) { };
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
            builtins.concatMap (
              pkg:
              map (feed2nix pkg) (
                # Prefer packages from default feeds from nix-openwrt-imagebuilder,
                # only add packages from openwrtPackages of custom feeds to extraPackages,
                builtins.filter (
                  feed:
                  !builtins.elem feed [
                    "base"
                    "luci"
                    "packages"
                    "routing"
                    "telephony"
                  ]
                ) pkg.feeds
              )
            ) openwrtPackages
          );
      };
  };
}
