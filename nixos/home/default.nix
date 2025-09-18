{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.users.users.${config.my.user}) name home;
in

{
  system.activationScripts.homeActivate = ''
    ${pkgs.shadow.su}/bin/su "${name}" --command '${config.home.activate} "${home}" /run/current-system/sw/home'
  '';
}
