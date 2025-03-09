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
    pkgs,
    system,
    ...
  }:
  let
    customPkgs = import nixpkgs {
      inherit system;
      overlays = (import ../overlays { inherit inputs; }) ++ overlays;
      config = {
        allowAliases = false;
        allowUnfree = true;
        android_sdk.accept_license = true;
      } // config;
    };
  in
  apply {
    inherit
      extraArgs
      inputs
      nixpkgs
      system
      ;
    pkgs = if (nixpkgs != inputs.nixpkgs || config != { } || overlays != [ ]) then customPkgs else pkgs;
    modules = defaultModules ++ modules;
  }
)
