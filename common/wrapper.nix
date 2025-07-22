{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

let
  wrapper-manager = import inputs.wrapper-manager;
in

{
  _module.args.wrapper = wrapper-manager.lib.wrapWith pkgs;

  wrappers.jujutsu.enable = true;
}
