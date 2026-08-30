{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../../lib/my.nix) mkReplaceStringsModule;
  inputs = import ../../inputs { };
  modulesPath = inputs.nixpkgs.outPath + "/nixos/modules";
in

{
  # https://github.com/NixOS/nixpkgs/blob/master/nixos/doc/manual/development/replace-modules.section.md
  # zsh module from nix-darwin is outdated, use the one from nixos
  disabledModules = [ "programs/zsh" ];

  # `hostname` on macOS does not accept `--fqdn` arg
  imports = [
    (mkReplaceStringsModule
      [ "hostname --fqdn" "./zinputrc" ]
      [
        "hostname -f"
        (modulesPath + "/programs/zsh/zinputrc")
      ]
      (modulesPath + "/programs/zsh/zsh.nix")
    )
  ];

  config = lib.mkIf config.programs.zsh.enable {
    # Important, the zsh module from nixos uses `__NIXOS_SET_ENVIRONMENT_DONE`,
    # but nix-darwin sets `__NIX_DARWIN_SET_ENVIRONMENT_DONE`, without this,
    # tools like `nix shell` are broken
    environment.variables.__NIXOS_SET_ENVIRONMENT_DONE = "1";
  };
}
