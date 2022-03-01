{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
   home.packages = [ pkgs.emacs ];
   home.file.".doom.d".source = ./doom.d;
}

else

{
  fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
}
