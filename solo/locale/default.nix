{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.variables.LANG = "en_US.UTF-8";
  environment.variables.LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
}
