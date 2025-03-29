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
      home-manager-path = inputs.home-manager.outPath;
      config.imports = [
        { my.nixpkgs.enable = false; }
        ../droid
      ] ++ modules;
      # Prevent nix-on-droid from using <nixpkgs>, see nix-on-droid/modules/nixpkgs/config.nix
      isFlake = true;
    };
in

{
  default = mkDroid { system = "aarch64-linux"; };

  # for CI
  droid = mkDroid { system = "x86_64-linux"; };
}
