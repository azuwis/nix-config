{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.variables.TERMINFO_DIRS = "${pkgs.ncurses}/share/terminfo";
}
