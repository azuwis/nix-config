{
  config,
  lib,
  pkgs,
  ...
}:

let
  inputs = import ../../inputs;
in

{
  # https://github.com/nix-darwin/nix-darwin/pull/1396
  # Remove when nix-darwin 25.11 released
  disabledModules = [ "system/applications.nix" ];
  imports = [ (inputs.nix-darwin-master + "/modules/system/applications.nix") ];
}
