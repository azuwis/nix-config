{
  config,
  lib,
  pkgs,
  ...
}:

{
  build.activation.home = ''
    ${config.home.activate} "$HOME" || true
  '';
}
