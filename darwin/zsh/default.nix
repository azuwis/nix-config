{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../../inputs;
  modulesPath = inputs.nixpkgs.outPath + "/nixos/modules";
in

{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/doc/manual/development/replace-modules.section.md
  # zsh module from nix-darwin are outdated, use the one from nixos
  disabledModules = [ "programs/zsh" ];

  imports = builtins.map (path: modulesPath + path) [
    "/programs/zsh/zsh.nix"
  ];

  config = lib.mkIf config.programs.zsh.enable {
    # Important, the zsh module from nixos use `__NIXOS_SET_ENVIRONMENT_DONE`,
    # but nix-darwin set `__NIX_DARWIN_SET_ENVIRONMENT_DONE`, without this,
    # tools like `nix shell` are broken
    environment.variables.__NIXOS_SET_ENVIRONMENT_DONE = "1";
  };
}
