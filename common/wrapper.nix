{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../inputs;
  wrapper-manager = import inputs.wrapper-manager;
in

{
  _module.args.wrapper = wrapper-manager.lib.wrapWith pkgs;

  wrappers.jujutsu.enable = true;
}
