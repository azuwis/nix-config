{ config, lib, pkgs, ... }:

let
  arch = if pkgs.stdenv.isDarwin then "darwin" else "linux";
  indexCache = pkgs.fetchurl {
    url = "https://github.com/Mic92/nix-index-database/releases/download/2022-01-09/index-x86_64-${arch}";
    sha256 = "sha256-lye/KGknE5KM62mFWt+LU4EM0i9BRGoj+JFe4RTbtQ8=";
  };
in

{
  home.file.".cache/nix-index/files".source = indexCache;
  programs.nix-index.enable = true;
}
