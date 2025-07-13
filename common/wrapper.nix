{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (import ../lib/my.nix) getWmModules;
  inputs = import ../inputs;
  wrapper-manager = import inputs.wrapper-manager;
  wm-eval = wrapper-manager.lib {
    inherit pkgs;
    modules = getWmModules [ ./. ] ++ [
      {
      }
    ];
  };
in

{
  environment.systemPackages = builtins.attrValues wm-eval.config.build.packages;
}
