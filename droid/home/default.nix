{
  config,
  lib,
  pkgs,
  ...
}:

{
  build.activation.home = ''
    ${config.home.activate} "$HOME" "$HOME/.nix-profile/home" || true
  '';
}
