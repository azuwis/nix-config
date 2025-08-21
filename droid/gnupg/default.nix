{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.etc."gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 14400
    max-cache-ttl 14400
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry
  '';
}
