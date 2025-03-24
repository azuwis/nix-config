let
  inputs = import ../inputs;
  pkgs = import ../pkgs { };

  openwrt-imagebuilder = inputs.nix-openwrt-imagebuilder.outPath;
  profiles = import (openwrt-imagebuilder + "/profiles.nix") { inherit pkgs; };

  mkOpenwrt =
    {
      profile,
      config ? { },
    }:
    import (openwrt-imagebuilder + "/builder.nix") (profiles.identifyProfile profile // config);
in

{
  openwrt = {
    xr500 = mkOpenwrt { profile = "netgear_xr500"; };
  };
}
