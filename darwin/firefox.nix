{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
  home.activation.legacyfox = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.rsync}/bin/rsync -a ${pkgs.legacyfox}/ /Applications/Firefox.app/Contents/Resources/
  '';
  programs.firefox.package = pkgs.runCommand "firefox-0.0.0" { } "mkdir $out";
}

else

{
  homebrew.casks = [ "firefox" ];
}
