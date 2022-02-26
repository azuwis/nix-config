{ config, lib, pkgs, ... }:

{
   home.packages = [ pkgs.emacsUnstable ];
   home.file.".doom.d".source = ./doom.d;
}
