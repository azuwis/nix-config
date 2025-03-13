{
  config,
  lib,
  pkgs,
  home-manager-path,
  ...
}:

let
  inherit (import ../lib) getHmModules getModules;
in

{
  imports = [ ../common ] ++ getModules [ ./. ];

  hm.imports = getHmModules [ ./. ];

  hm.my.ssh-agent.enable = true;
  hm.programs.zsh.logoutExtra = ''
    pkill ssh-agent
  '';
}
