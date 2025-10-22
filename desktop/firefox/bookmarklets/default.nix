{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.firefox;
in

{
  config = lib.mkIf cfg.enable {
    programs.firefox.policies.Bookmarks = builtins.fromJSON (builtins.readFile ./bookmarklets.json);
  };
}
