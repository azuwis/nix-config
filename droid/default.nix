{
  config,
  lib,
  pkgs,
  home-manager-path,
  ...
}:

let
  inherit (import ../lib/my.nix) getHmModules getModules;
  inherit (lib) mkAliasOptionModule;
in

{
  imports = [
    (mkAliasOptionModule
      [
        "home-manager"
        "users"
        config.my.user
      ]
      [
        "home-manager"
        "config"
      ]
    )
    (mkAliasOptionModule
      [
        "environment"
        "systemPackages"
      ]
      [
        "environment"
        "packages"
      ]
    )
    (mkAliasOptionModule
      [
        "environment"
        "variables"
      ]
      [
        "environment"
        "sessionVariables"
      ]
    )
    ../common
    ../common/home-manager.nix
    ../common/nixpkgs
    ../common/registry
  ] ++ getModules [ ./. ];

  user.shell = "${pkgs.zsh}/bin/zsh";

  hm.imports = getHmModules [ ./. ];

  hm.my.ssh-agent.enable = true;
  hm.programs.zsh.logoutExtra = ''
    [ "$TTY" = /dev/pts/0 ] && [ -n "$SSH_AGENT_PID" ] && kill "$SSH_AGENT_PID"
  '';
}
