{ inputs, withSystem, ... }:

let
  mkOpenwrt =
    {
      profile,
      config ? { },
    }:
    withSystem "x86_64-linux" (
      { pkgs, ... }:
      let
        profiles = inputs.openwrt-imagebuilder.lib.profiles { inherit pkgs; };
      in
      inputs.openwrt-imagebuilder.lib.build (profiles.identifyProfile profile // config)
    );
in
{
  flake.packages.x86_64-linux = {
    xr500 = mkOpenwrt { profile = "netgear_xr500"; };
  };

  perSystem =
    {
      self',
      inputs',
      pkgs,
      ...
    }:
    {
      packages.dewclaw = import inputs.dewclaw {
        inherit pkgs;
        configuration = ../hosts/dewclaw.nix;
      };
    };
}
