{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

let
  emacs = if pkgs.stdenv.isDarwin then pkgs.emacsMac else pkgs.emacs;
in

{
   home.packages = [ emacs ];
   home.file.".doom.d".source = ./doom.d;
}

else

{
  fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
}
