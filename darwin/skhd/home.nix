{ config, lib, pkgs, ... }:

{
  home.activation.skhd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.skhd}/bin/skhd --reload || /usr/bin/killall skhd || true
  '';
}
