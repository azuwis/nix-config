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
  # Need to set LOCALE_ARCHIVE before running for zsh locale support
  programs.zsh.env = {
    LANG = "en_US.UTF-8";
    LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
  };
}
