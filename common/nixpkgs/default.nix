{
  config,
  lib,
  pkgs,
  ...
}:

{
  nixpkgs = {
    config = import ../../config.nix;
    overlays = (import ../../overlays);
  };
}
