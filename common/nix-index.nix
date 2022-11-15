{ config, lib, pkgs, ... }:

let
  indexCache = {
    darwin = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2022-11-06/index-x86_64-darwin";
      sha256 = "0wq0f746fqng3d7cj1nk71zmm5rzb302qry5lyly03ffaws08f9n";
    };
    linux = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/download/2022-11-06/index-x86_64-linux";
      sha256 = "0a7sn64hlriah7br4lyjwf3l3n5rnwc9hb79lk870czl2rhdr706";
    };
  }.${pkgs.stdenv.hostPlatform.parsed.kernel.name};
in

{
  home.file.".cache/nix-index/files".source = indexCache;
  programs.nix-index.enable = true;
}
