{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./solo.nix
  ];

  nix.singleUser = true;
}
