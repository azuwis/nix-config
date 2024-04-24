{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${pkgs.pinentry-curses}/bin/pinentry
  '';
}
