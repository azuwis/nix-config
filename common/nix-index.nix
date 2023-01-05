{ config, lib, pkgs, ... }:

let
  indexCache = {
    darwin = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2023-01-01-032240/index-x86_64-darwin";
      sha256 = "1j9ipl9a43wvrfyqk7v97fsj0rh0ka7l8raigd55j9s6ijr4n8cy";
    };
    linux = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2023-01-01-032240/index-x86_64-linux";
      sha256 = "12nb9qi5qfl8gw9iscayf2204alrllaf98i2x2gwg748vy2c3z44";
    };
  }.${pkgs.stdenv.hostPlatform.parsed.kernel.name};
in

{
  home.file.".cache/nix-index/files".source = indexCache;
  programs.nix-index.enable = true;
}
