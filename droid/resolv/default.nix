{
  config,
  lib,
  pkgs,
  ...
}:

{
  # https://github.com/termux/termux-packages/issues/1174
  environment.etc."resolv.conf".enable = false;
  environment.packages = [
    (pkgs.runCommand "resolvconf" { } ''
      mkdir -p $out/bin
      install -m 0755 ${./resolvconf.sh} $out/bin/resolvconf
    '')
  ];
  hm.programs.zsh.initExtra = ''
    resolvconf
  '';
}
