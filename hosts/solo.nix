{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../solo
  ];

  nixpkgs.hostPlatform = builtins.currentSystem;
}
