{ config, lib, pkgs, ... }:

let
  inherit (lib) mdDoc mkEnableOption mkIf;
  cfg = config.my.nnn;

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
  nnn = pkgs.nnn.override ({ withNerdIcons = true; });
  nnn-wrapped = with pkgs; runCommand "nnn" { buildInputs = [ makeWrapper ]; } ''
    makeWrapper ${nnn}/bin/nnn $out/bin/nnn \
      --add-flags -Acd \
      --set GUI 1 \
      --set NNN_OPENER "${./nuke}" \
      --set NNN_BMS "${renderSettings bookmarks}"
    ln -s ${gnused}/bin/sed $out/bin/gsed
    ln -s ${nnn}/share $out/share
  '';
in
{
  options.my.nnn = {
    enable = mkEnableOption (mdDoc "nnn");
  };

  config = mkIf cfg.enable {
    home.packages = [ nnn-wrapped ];
    home.shellAliases = { n = "nnn"; };
  };
}
