{ config, lib, pkgs, ... }:

let
  indexCache = {
    darwin = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2022-10-16/index-x86_64-darwin";
      sha256 = "09rzyjjw5kahgywjxczn2zyyz1y93rg08mafi30iaga1n9z8nh4w";
    };
    linux = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2022-10-16/index-x86_64-linux";
      sha256 = "1f7hil8q2iig5742sipzskgv7anchl84i74hayqxz80w0mkjp6i7";
    };
  }.${pkgs.stdenv.hostPlatform.parsed.kernel.name};
in

{
  home.file.".cache/nix-index/files".source = indexCache;
  programs.nix-index.enable = true;
}
