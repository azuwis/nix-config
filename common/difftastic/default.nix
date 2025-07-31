{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.wrappers.difftastic;
in
{
  options.wrappers.difftastic = {
    enable = mkEnableOption "difftastic";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.difftastic ];
    wrappers.git.config = {
      alias.df = "difftool";
      diff.tool = "difftastic";
      difftool.prompt = false;
      difftool.difftastic = {
        cmd = ''difft "$LOCAL" "$REMOTE"'';
      };
      pager.difftool = true;
    };
  };
}
