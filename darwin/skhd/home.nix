{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.activation.skhd = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.skhd}/bin/skhd --reload || $DRY_RUN_CMD /usr/bin/killall skhd || true
  '';
}
