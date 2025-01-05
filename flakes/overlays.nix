{
  inputs,
  self,
  lib,
  ...
}:
{
  flake.overlays.packages = import "${inputs.nixpkgs}/pkgs/top-level/by-name-overlay.nix" ../pkgs/by-name;
  flake.overlays.yuzu = final: prev: {
    # error: 'VK_DRIVER_ID_MESA_AGXV' was not declared in this scope
    yuzu-ea = lib.optionalAttrs final.stdenv.isLinux (
      inputs.yuzu.packages.${final.stdenv.system}.early-access.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            rm -r externals/Vulkan-Utility-Libraries
            ln -s ${final.vulkan-utility-libraries.src} externals/Vulkan-Utility-Libraries
          '';
      })
    );
  };
  flake.overlays.jovian = import ../overlays/jovian.nix;

  flake.overlays.default = lib.composeManyExtensions [
    inputs.agenix.overlays.default
    self.overlays.packages
    self.overlays.yuzu
    (import ../overlays/default.nix { inherit inputs; })
    (import ../overlays/lix.nix)
  ];

  perSystem =
    { lib, system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowAliases = false;
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
        overlays = [ self.overlays.default ];
      };
    in
    {
      _module.args.pkgs = pkgs;

      packages = lib.filterAttrs (_: value: value ? type && value.type == "derivation") (
        builtins.mapAttrs (name: _: pkgs.${name}) (self.overlays.default { } { })
      );
    };
}
