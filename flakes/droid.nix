{
  inputs,
  withSystem,
  ...
}:

let
  mkDroid = import ./mk-system.nix {
    inherit inputs withSystem;
    defaultSystem = "aarch64-linux";
    defaultModules = [ ../droid ];
    apply =
      args@{ ... }:
      args.inputs.droid.lib.nixOnDroidConfiguration {
        inherit (args) pkgs modules;
        extraSpecialArgs = {
          inherit (args) inputs;
        };
      };
  };
in
{
  flake.nixOnDroidConfigurations.default = mkDroid {
    # `pkgs.system` is used and breaks `config.allowaliases = false`
    # https://github.com/nix-community/nix-on-droid/blob/5d88ff2519e4952f8d22472b52c531bb5f1635fc/flake.nix#L82
    config.allowAliases = true;
  };

  # for CI
  flake.nixOnDroidConfigurations.droid = mkDroid {
    config.allowAliases = true;
    system = "x86_64-linux";
  };
}
