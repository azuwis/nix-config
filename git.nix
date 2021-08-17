{ config, lib, pkgs, ... }:

let
  email = config.my.email;
  name = config.my.name;
in
{
  home-manager.users."${config.my.user}" = { config, lib, pkgs, ... }: {
    programs.git = {
      enable = true;
      userEmail = email;
      userName = name;
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
  };
}
