{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib) getModules;
in

{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [
      "home-manager"
      "users"
      config.my.user
    ])
  ] ++ getModules [ ./. ];

  hm.imports = [ ./home.nix ];

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
  home-manager.useGlobalPkgs = true;
  # do not enable home-manager.useUserPackages, to match standalone home-manager,
  # so home-manager/nixos-rebuild/darwin-rebuild can be used at the same time
  # home-manager.useUserPackages = true;
}
