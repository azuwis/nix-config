{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.difftastic ];
  programs.git.aliases.df = "difftool";
  programs.git.extraConfig = {
    diff.tool = "difftastic";
    difftool.prompt = false;
    difftool.difftastic = { cmd = ''difft "$LOCAL" "$REMOTE"''; };
    pager.difftool = true;
  };
}
