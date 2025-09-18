{
  config,
  lib,
  pkgs,
  ...
}:

{
  system.activationScripts.postActivation.text = ''
    su "${config.system.primaryUser}" -c '${config.home.activate} "${config.system.primaryUserHome}" /run/current-system/sw/home' || true
  '';
}
