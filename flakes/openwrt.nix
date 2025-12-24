let
  inputs = import ../inputs;
  pkgs = import ../pkgs {
    # openwrt-imagebuilder runs only in x86_64-linux
    # https://openwrt.org/docs/guide-user/additional-software/imagebuilder
    system = "x86_64-linux";
  };

  openwrt-imagebuilder = inputs.nix-openwrt-imagebuilder.outPath;

  mkOpenwrt =
    {
      profile,
      config ? { },
      ignoreHashUrlRegex ? "",
    }:
    let
      fetchurl =
        args:
        if
          builtins ? currentSystem # Not in pure mode
          && ignoreHashUrlRegex != ""
          && builtins.match ignoreHashUrlRegex args.url != null
        then
          # Override pkgs.fetchurl with builtins.fetchurl, remove sha256 arg to let it
          # works in impure mode, another way to workaround hash mismatch problem
          # https://github.com/astro/nix-openwrt-imagebuilder/?tab=readme-ov-file#refreshing-hashes
          builtins.trace "Ignore hash of ${args.url}" (builtins.fetchurl (removeAttrs args [ "sha256" ]))
        else
          pkgs.fetchurl args;
      profiles = import (openwrt-imagebuilder + "/profiles.nix") {
        pkgs = pkgs // {
          inherit fetchurl;
        };
      };
    in
    import (openwrt-imagebuilder + "/builder.nix") (profiles.identifyProfile profile // config);
in

{
  wg3526 = mkOpenwrt {
    profile = "zbtlink_zbt-wg3526-16m";
    # ignoreHashUrlRegex = "https://downloads\.openwrt\.org/.*/[a-z]+/Packages";
  };

  xr500 = mkOpenwrt { profile = "netgear_xr500"; };
}
