{
  config,
  lib,
  pkgs,
  ...
}:

# let
#   inherit (config.users.users.${config.my.user}) name home;
# in

{
  # system.activationScripts.activateHome = ''
  #   ${pkgs.shadow.su}/bin/su "${name}" --command '${config.home.activate} "${home}"'
  # '';

  # journalctl --user --unit nixos-activation
  system.userActivationScripts.activateHome = ''
    ${config.home.activate} "$HOME"
  '';
}
