{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.wrappers.git;
  scripts = ./scripts;
in
{
  imports = [ ./impl.nix ];

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git-crypt
      git-remote-gcrypt
    ];
    wrappers.git.config = {
      user = { inherit (config.my) email name; };
      alias = {
        br = "branch";
        ci = "commit";
        co = "checkout";
        cp = "cherry-pick";
        di = "diff";
        fixup = "!f() { git commit --fixup=$1 && git rebase --interactive --autosquash $1~; }; f";
        fork = "!f() { url=$(git remote get-url origin); git remote add \"$USER\" \"\${url%/*/*}/$USER/\${url##*/}\"; git remote show -n \"$USER\"; }; f";
        gch = "!git reflog expire --expire=now --all && git gc --prune=now --aggressive";
        lg = "log --abbrev-commit --graph --date=relative --pretty=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset'";
        ni = "!${scripts}/ni";
        pfork = "!f() { url=$(git remote get-url origin); git push \"\${url%/*/*}/\${1%%:*}/\${url##*/}\" HEAD:\"\${1#*:}\"; }; f";
        st = "status";
        rewind = "!f() { git update-ref refs/heads/$1 \${2:-HEAD}; }; f";
      };
      core.excludesFile = pkgs.writeText "git-excludes-file" ''
        .*.sw?
        .direnv/
        .envrc
      '';
      rebase = {
        autosquash = true;
        autostash = true;
        stat = true;
      };
      rerere = {
        autoupdate = true;
        enabled = true;
      };
      status = {
        submoduleSummary = true;
      };
      url = {
        "ssh://git@github.com:22/" = {
          pushInsteadOf = "https://github.com/";
        };
        "ssh://git@codeberg.org:22/" = {
          pushInsteadOf = "https://codeberg.org/";
        };
      };
    };
  };
}
