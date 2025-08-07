{
  config,
  lib,
  pkgs,
  home-manager-path,
  ...
}:

let
  inherit (import ../lib/my.nix) getHmModules getModules;
in

{
  imports = [
    ../common
    ../common/home-manager.nix
  ] ++ getModules [ ./. ];

  hm.imports = getHmModules [ ./. ];

  hm.my.ssh-agent.enable = true;
  hm.programs.zsh.logoutExtra = ''
    [ "$TTY" = /dev/pts/0 ] && [ -n "$SSH_AGENT_PID" ] && kill "$SSH_AGENT_PID"
  '';
}
