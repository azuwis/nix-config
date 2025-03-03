{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.etc."sudoers.d/custom".text = ''
    Defaults timestamp_timeout=300
  '';
  security.pam.services.sudo_local.touchIdAuth = true;
}
