{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getModules;
in

{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" config.my.user ])
  ] ++ getModules [ ./. ];

  _module.args.inputs = import ../inputs;

  hm.imports = [ ./home.nix ];

  home-manager.useGlobalPkgs = true;
  # do not enable home-manager.useUserPackages, to match standalone home-manager,
  # so home-manager/nixos-rebuild/darwin-rebuild can be used at the same time
  # home-manager.useUserPackages = true;
}
