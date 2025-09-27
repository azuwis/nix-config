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
  disabledModules = [ ../../common/system ];

  imports = builtins.map (path: modulesPath + path) [
    "/config/nix-flakes.nix"
    "/config/shells-environment.nix"
    "/misc/assertions.nix"
    "/misc/meta.nix"
    "/misc/nixpkgs.nix"
    "/programs/bash/bash-completion.nix"
    "/programs/bash/bash.nix"
    "/programs/command-not-found/command-not-found.nix"
    "/programs/direnv.nix"
    "/programs/fish.nix"
    "/programs/git.nix"
    "/programs/nix-index.nix"
    "/programs/xonsh.nix"
    "/programs/yazi.nix"
    "/programs/zsh/zsh.nix"
    "/system/etc/etc.nix"
  ];

  options = {
    documentation.man.generateCaches = mkOption { };
    environment.sessionVariables = mkOption { default = { }; };
    environment.profileRelativeSessionVariables = mkOption { default = { }; };
    networking.fqdnOrHostName = mkOption { default = "nix"; };
    nix.nixPath = mkOption { };
    system.activationScripts = mkOption { };
    users.defaultUserShell = mkOption { };
  };
}
