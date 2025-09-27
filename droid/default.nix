{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
  inherit (lib) mkAliasOptionModule;
in

{
  imports = [
    (mkAliasOptionModule [ "environment" "systemPackages" ] [ "environment" "packages" ])
    ../common
  ]
  ++ getModules [ ./. ];

  user.shell = "${pkgs.zsh}/bin/zsh";

  programs.zsh.ssh-agent.enable = true;
  environment.etc.zlogout.text = ''
    [ "$TTY" = /dev/pts/0 ] && [ -n "$SSH_AGENT_PID" ] && kill "$SSH_AGENT_PID"
  '';
}
