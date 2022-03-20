{ config, lib, pkgs, ... }:

let
  indexCache = {
    darwin = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2022-03-20/index-x86_64-darwin";
      sha256 = "0359mv6pxgk9hsi2sq50p9xr8d89lajy3f67rilwq777wvqrgs55";
    };
    linux = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2022-03-20/index-x86_64-linux";
      sha256 = "10kwka1314miqc4c11qkp5r1s4d2j1dxzl3bg6rvx6lxmxqhywn2";
    };
  }.${pkgs.stdenv.hostPlatform.parsed.kernel.name};
in

{
  home.file.".cache/nix-index/files".source = indexCache;
  programs.nix-index.enable = true;
}
