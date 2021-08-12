{ config, pkgs, ... }:

{
  home-manager.users."${config.my.user}".programs.git = {
    enable = true;
    userEmail = config.my.email;
    userName = config.my.name;
    aliases = {
      ci = "commit";
      cp = "cherry-pick";
      fixup = "!sh -c 'git commit --fixup=$1 && git rebase --interactive --autosquash $1~' -";
      lg = "log --abbrev-commit --graph --date=relative --pretty=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset'";
      st = "status";
    };
    ignores = [
      "*.swp"
    ];
    extraConfig = {
      url = {
        "ssh://git@github.com:22/" = { pushInsteadOf = "https://github.com/"; };
      };
    };
  };
}
