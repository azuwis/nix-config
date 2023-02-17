{ config, lib, pkgs, ... }:

let
  indexCache = {
    aarch64-darwin = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2023-02-12-032305/index-aarch64-darwin";
      sha256 = "0206izp6nk3yixah4c77pvyvqiab0i209hpi24z8z9vf9xkcf1km";
    };
    aarch64-linux = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2023-02-12-032305/index-aarch64-linux";
      sha256 = "0k3blna0mwvlgxfhxgdswm1fpx0j0r0pwzfki6c05nrymb6rvx1r";
    };
    x86_64-darwin = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2023-02-12-032305/index-x86_64-darwin";
      sha256 = "08qz1qmsg0da32h4mlz9w0kcjf7v5yz93fx4n9mxc65aadn3w40f";
    };
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2023-02-12-032305/index-x86_64-linux";
      sha256 = "0l2311jz1acxg1mzrxf6maxzk9gvg68i5jpxlgc3vglg78havkzs";
    };
  }.${pkgs.stdenv.system};
in

{
  home.file.".cache/nix-index/files".source = indexCache;
  programs.nix-index.enable = true;
}
