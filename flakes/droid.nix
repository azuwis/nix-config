{
  inputs,
  ...
}:

let
  pkgsFor =
    system:
    import inputs.nixpkgs {
      inherit system;
      config = import ../config.nix // {
        # `pkgs.system` is used and breaks `config.allowaliases = false`
        # https://github.com/nix-community/nix-on-droid/blob/5d88ff2519e4952f8d22472b52c531bb5f1635fc/flake.nix#L82
        allowAliases = true;
      };
      overlays = import ../overlays { };
    };
  mkDroid =
    {
      system ? "aarch64-linux",
      modules ? [ ],
    }:
    inputs.droid.lib.nixOnDroidConfiguration {
      pkgs = pkgsFor system;
      modules = [ ../droid ] ++ modules;
    };
in

{
  flake.nixOnDroidConfigurations.default = mkDroid { };

  # for CI
  flake.nixOnDroidConfigurations.droid = mkDroid {
    system = "x86_64-linux";
  };
}
