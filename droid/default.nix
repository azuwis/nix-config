{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
  inherit (lib) mkAliasOptionModule;
  inputs = import ../inputs;
  modulesPath = inputs.nixpkgs.outPath + "/nixos/modules";
in

{
  imports =
    builtins.map (path: modulesPath + path) [
      "/config/shells-environment.nix"
      "/misc/extra-arguments.nix"
      "/programs/bash/bash.nix"
      "/programs/command-not-found/command-not-found.nix"
      "/programs/direnv.nix"
      "/programs/fish.nix"
      "/programs/git.nix"
      "/programs/nix-index.nix"
      "/programs/xonsh.nix"
      "/programs/yazi.nix"
      "/programs/zsh/zsh.nix"
    ]
    ++ [
      (mkAliasOptionModule [ "environment" "systemPackages" ] [ "environment" "packages" ])
      ../common
      ../common/nixpkgs
      ../common/registry
    ]
    ++ getModules [ ./. ];

  user.shell = "${pkgs.zsh}/bin/zsh";

  programs.zsh.ssh-agent.enable = true;
  environment.etc.zlogout.text = ''
    [ "$TTY" = /dev/pts/0 ] && [ -n "$SSH_AGENT_PID" ] && kill "$SSH_AGENT_PID"
  '';
}
