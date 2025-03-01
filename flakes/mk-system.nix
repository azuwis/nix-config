{
  inputs,
  withSystem,
  defaultSystem,
  defaultModules,
  apply,
}:

extraArgs@{
  system ? defaultSystem,
  nixpkgs ? inputs.nixpkgs,
  config ? { },
  overlays ? [ ],
  modules ? [ ],
  ...
}:

withSystem system (
  {
    inputs',
    lib,
    pkgs,
    system,
    ...
  }:
  let
    customPkgs = import nixpkgs (
      lib.recursiveUpdate {
        inherit system;
        overlays = (import ../overlays { inherit inputs; }) ++ overlays;
        config = {
          allowAliases = false;
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      } { inherit config; }
    );
  in
  apply {
    inherit
      extraArgs
      inputs
      inputs'
      lib
      nixpkgs
      system
      ;
    pkgs = if (nixpkgs != inputs.nixpkgs || config != { } || overlays != [ ]) then customPkgs else pkgs;
    modules = defaultModules ++ modules;
  }
)
