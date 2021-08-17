{ config, lib, pkgs, ... }:

{
  home-manager.users."${config.my.user}".programs.direnv.enable = true;
  services.lorri.enable = true;
}
