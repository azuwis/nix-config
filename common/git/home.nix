{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.git;
in
{
  options.my.git = {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      git-crypt
      git-remote-gcrypt
    ];
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
        fixup = "!f() { git commit --fixup=$1 && git rebase --interactive --autosquash $1~; }; f";
        fork = "!f() { url=$(git remote get-url origin); git remote add \"$USER\" \"\${url%/*/*}/$USER/\${url##*/}\"; git remote show -n \"$USER\"; }; f";
        gch = "!git reflog expire --expire=now --all && git gc --prune=now --aggressive";
        lg = "log --abbrev-commit --graph --date=relative --pretty=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset'";
        st = "status";
        rewind = "!f() { git update-ref refs/heads/$1 \${2:-HEAD}; }; f";
      };
      ignores = [
        ".*.sw?"
        ".direnv/"
        ".envrc"
      ];
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
  };
}
