{
  inputs,
  config,
  lib,
  pkgs,
  home-manager-path,
  ...
}:

{
  imports = [ ../common ] ++ inputs.lib.getModules [ ./. ];

  hm.imports = inputs.lib.getHmModules [ ./. ];

  hm.my.ssh-agent.enable = true;
  hm.programs.zsh.logoutExtra = ''
    pkill ssh-agent
  '';
}
