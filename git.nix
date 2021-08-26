{ config, lib, pkgs, ... }:

{
  home.packages = [ pkgs.git-remote-gcrypt ];
  programs.git = {
    enable = true;
    userEmail = config.my.email;
    userName = config.my.name;
    aliases = {
      br = "branch";
      ci = "commit";
      co = "checkout";
      cp = "cherry-pick";
      di = "diff";
      fixup = "!sh -c 'git commit --fixup=$1 && git rebase --interactive --autosquash $1~' -";
      gch = "!sh -c 'git reflog expire --expire=now --all && git gc --prune=now --aggressive'";
      lg = "log --abbrev-commit --graph --date=relative --pretty=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset'";
      st = "status";
      rewind = "!sh -c 'git update-ref refs/heads/$1 \${2:-HEAD}' -";
    };
    ignores = [ ".*.sw?" ];
    extraConfig = {
      rebase = {
        autosquash = true;
        autostash = true;
        stat = true;
      };
      rerere = {
        autoupdate = true;
        enabled = true;
      };
      status = { submoduleSummary = true; };
      url = {
        "ssh://git@github.com:22/" = { pushInsteadOf = "https://github.com/"; };
      };
    };
  };
}
