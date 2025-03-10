{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    "${inputs.agenix.outPath}/modules/age.nix"
    "${inputs.home-manager.outPath}/nix-darwin"
    ../common
  ] ++ inputs.lib.getModules [ ./. ];

  hm.imports = [ ./home.nix ];

  environment.systemPackages = [ pkgs.agenix ];
}
