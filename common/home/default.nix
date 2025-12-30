{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = import ../../lib/linkdir.nix {
    inherit config lib pkgs;
    optionName = "home";
    realDir = "$HOME";
  };
}
