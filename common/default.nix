{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [
      "home-manager"
      "users"
      config.my.user
    ])
  ] ++ inputs.lib.getModules [ ./. ];

  hm.imports = [ ./home.nix ];

  home-manager.extraSpecialArgs = {
    inherit inputs;
  };
  home-manager.useGlobalPkgs = true;
  # do not enable home-manager.useUserPackages, to match standalone home-manager,
  # so home-manager/nixos-rebuild/darwin-rebuild can be used at the same time
  # home-manager.useUserPackages = true;
}
