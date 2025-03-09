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
    "${inputs.agenix.outPath}/modules/age.nix"
    "${inputs.home-manager.outPath}/nix-darwin"
    ../common
  ] ++ getModules [ ./. ];

  hm.imports = [ ./home.nix ];

  environment.systemPackages = [ pkgs.agenix ];
}
