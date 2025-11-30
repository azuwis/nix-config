{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption;
  inputs = import ../../inputs;
  modulesPath = inputs.nixpkgs.outPath + "/nixos/modules";
in

{
  disabledModules = [ ../../common/nixpkgs/default.nix ];

  imports = map (path: modulesPath + path) [
    "/config/shells-environment.nix"
    "/misc/extra-arguments.nix"
    "/misc/meta.nix"
    "/programs/bash/bash.nix"
    "/programs/direnv.nix"
    "/programs/fish.nix"
    "/programs/git.nix"
    "/programs/less.nix"
    "/programs/nix-index.nix"
    "/programs/xonsh.nix"
    "/programs/yazi.nix"
    "/programs/zsh/zsh.nix"
  ];

  options = {
    documentation.man.generateCaches = mkOption { };
    environment.pathsToLink = mkOption { };
    environment.profileRelativeSessionVariables = mkOption { default = { }; };
    networking.fqdnOrHostName = mkOption { default = "droid"; };
    nix.optimise = mkOption { };
    system.activationScripts = mkOption { };
    system.build = mkOption { };
    users.defaultUserShell = mkOption { };
  };
}
