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

  hm.my.ssh-agent.enable = true;
}
