{ config, lib, pkgs, ... }:

let
  indexCache = {
    darwin = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/latest/download/index-x86_64-darwin";
      sha256 = "05gr9w15bpvm3kai0gz5bg0w2nv74v8srm1v8im6yf1qr0823vin";
    };
    linux = pkgs.fetchurl {
      url = "https://github.com/Mic92/nix-index-database/releases/latest/download/index-x86_64-linux";
      sha256 = "0qz243j42502fcqb9xah5sda8y408qb933mm3hzgw0bjydhk1k2q";
    };
  }.${pkgs.stdenv.hostPlatform.parsed.kernel.name};
in

{
  home.file.".cache/nix-index/files".source = indexCache;
  programs.nix-index.enable = true;
}
