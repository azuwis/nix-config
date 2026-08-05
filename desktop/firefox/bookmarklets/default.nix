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
  config = lib.mkIf cfg.enhance {
    programs.firefox.policies.Bookmarks = builtins.fromJSON (builtins.readFile ./bookmarklets.json);
  };
}
