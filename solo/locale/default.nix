{
  config,
  lib,
  pkgs,
  ...
}:

let
  glibcLocales = pkgs.glibcLocales.override {
    allLocales = false;
    locales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };
in

{
  environment.variables.LANG = "en_US.UTF-8";
  environment.variables.LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
}
