{
  inputs,
  ...
}:

let
  mkDroid = import "${inputs.droid.outPath}/modules" {
    home-manager-path = inputs.home-manager.outPath;
    config.imports = [ ../droid ];
  };
in

{
  flake.nixOnDroidConfigurations.default = mkDroid;

  # for CI
  flake.nixOnDroidConfigurations.droid = mkDroid;
}
