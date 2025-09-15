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

  nixpkgs.hostPlatform = if builtins ? currentSystem then builtins.currentSystem else "x86_64-linux";
}
