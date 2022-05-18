{ config, lib, pkgs, ... }:

{
  age.identityPaths = [ "/etc/age/keys.txt" ];
}
