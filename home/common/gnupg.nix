{ config, lib, pkgs, ... }:

{
  home.file.".gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 14400
    max-cache-ttl 14400
  '';
}
