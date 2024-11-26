{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  cfg = config.my.firefox;
in
{
  config = mkIf cfg.enable {
    home.activation.legacyfox = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.rsync}/bin/rsync -a ${pkgs.legacyfox}/lib/firefox/ /Applications/Firefox.app/Contents/Resources/
    '';

    programs.firefox.package = pkgs.runCommand "firefox-0.0.0" { } "mkdir $out";
  };
}
