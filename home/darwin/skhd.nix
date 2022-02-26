{ config, lib, pkgs, ... }:

{
  home.activation.skhd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.skhd}/bin/skhd --reload || killall skhd || true
  '';
}
