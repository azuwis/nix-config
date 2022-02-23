{ config, lib, pkgs, ... }:

let
  renderSetting = key: value: "${key}:${value}";
  renderSettings = settings:
    lib.concatStringsSep ";" (lib.mapAttrsToList renderSetting settings);
  bookmarks = {
    c = "~/Documents";
    d = "~/Downloads";
    m = "~/Music";
    p = "~/Pictures";
    s = "~/src";
    v = "~/Videos";
  };
  nnn-wrapped = with pkgs; runCommandNoCC "nnn" { buildInputs = [ makeWrapper ]; } ''
    makeWrapper ${nnn.override({ withNerdIcons = true; })}/bin/nnn $out/bin/nnn \
      --add-flags -c \
      --set GUI 1 \
      --set NNN_OPENER "${./nuke}" \
      --set NNN_BMS "${renderSettings bookmarks}"
  '';
in

{
  home.packages = [ nnn-wrapped ];
}
