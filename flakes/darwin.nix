let
  inputs = import ../inputs;
  nixpkgs = inputs.nixpkgs.outPath;
  lib = import "${nixpkgs}/lib";

  mkDarwin =
    host:
    import "${inputs.nix-darwin.outPath}/eval-config.nix" {
      inherit lib;
      modules = [
        (../hosts + "/${host}.nix")
      ];
    };
in

{
  darwinConfigurations = lib.genAttrs [
    "mbp"
  ] mkDarwin;
}
