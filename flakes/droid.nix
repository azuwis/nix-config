let
  inputs = import ../inputs;

  mkDroid =
    {
      system,
      modules ? [ ],
    }:
    import (inputs.nix-on-droid.outPath + "/modules") {
      pkgs = import ../pkgs { inherit system; };
      targetSystem = system;
      config.imports = [
        ../droid
      ]
      ++ modules;
      # Prevent nix-on-droid from using <nixpkgs>, see nix-on-droid/modules/nixpkgs/config.nix
      isFlake = true;
    };
in

{
  default = mkDroid { system = "aarch64-linux"; };

  # for CI
  droid = mkDroid { system = "x86_64-linux"; };
}
