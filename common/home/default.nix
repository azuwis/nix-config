{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = import ../../lib/linkdir.nix {
    inherit config lib pkgs;
    name = "home";
    dir = "$HOME";
  };
}
