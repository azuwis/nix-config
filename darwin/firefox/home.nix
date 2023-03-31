{ config, lib, pkgs, ... }:

{
  home.activation.legacyfox = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.rsync}/bin/rsync -a ${pkgs.legacyfox}/lib/firefox/ /Applications/Firefox.app/Contents/Resources/
  '';
  programs.firefox.package = pkgs.runCommand "firefox-0.0.0" { } "mkdir $out";
}