{ config, lib, pkgs, ... }:

if builtins.hasAttr "hm" lib then

{
   home.packages = [ pkgs.emacsUnstable ];
}

else

{
  fonts.fonts = [ pkgs.emacs-all-the-icons-fonts ];
}
