{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getHmModules getModules;
  inherit (lib) mkAliasOptionModule;
  inputs = import ../inputs;
  nixpkgs = inputs.nixpkgs.outPath;
  modulesPath = nixpkgs + "/nixos/modules/";
in

{
  imports =
    builtins.map (path: modulesPath + path) [
      "config/shells-environment.nix"
      "misc/extra-arguments.nix"
      "programs/git.nix"
      "programs/zsh/zsh.nix"
    ]
    ++ [
      (mkAliasOptionModule [ "home-manager" "users" config.my.user ] [ "home-manager" "config" ])
      (mkAliasOptionModule [ "environment" "systemPackages" ] [ "environment" "packages" ])
      ../common
      ../common/home-manager.nix
      ../common/nixpkgs
      ../common/registry
    ]
    ++ getModules [ ./. ];

  user.shell = "${pkgs.zsh}/bin/zsh";

  hm.imports = getHmModules [ ./. ];

  hm.my.ssh-agent.enable = true;
  hm.programs.zsh.logoutExtra = ''
    [ "$TTY" = /dev/pts/0 ] && [ -n "$SSH_AGENT_PID" ] && kill "$SSH_AGENT_PID"
  '';
}
