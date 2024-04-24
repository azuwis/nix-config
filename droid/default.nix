{
  config,
  lib,
  pkgs,
  home-manager-path,
  ...
}:

{
  imports = [ ../common ] ++ lib.my.getModules [ ./. ];

  hm.imports = lib.my.getHmModules [ ./. ];

  hm.my.zsh-ssh-agent.enable = true;
}
