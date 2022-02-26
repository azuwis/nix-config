{ config, lib, pkgs, ... }:

{
  environment.etc."sudoers.d/kitty".text = ''
    Defaults env_keep += "TERMINFO_DIRS"
  '';
}
