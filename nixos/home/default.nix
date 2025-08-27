{
  config,
  lib,
  pkgs,
  ...
}:

{
  systemd.user.tmpfiles.rules = builtins.map (
    entry: "L+ %h/${entry.target} - - - - ${entry.source}"
  ) (lib.attrValues config.home.file);
}
