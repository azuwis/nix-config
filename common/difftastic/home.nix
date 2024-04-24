{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.difftastic;
in
{
  options.my.difftastic = {
    enable = mkEnableOption "difftastic";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.difftastic ];
    programs.git.aliases.df = "difftool";
    programs.git.extraConfig = {
      diff.tool = "difftastic";
      difftool.prompt = false;
      difftool.difftastic = {
        cmd = ''difft "$LOCAL" "$REMOTE"'';
      };
      pager.difftool = true;
    };
  };
}
