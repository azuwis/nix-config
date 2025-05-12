{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.my.resolv;
in
{
  options.my.resolv = {
    enable = mkEnableOption "resolv" // {
      default = true;
    };
    implement = mkOption {
      type = types.enum [
        "connectivity"
        "wifi"
      ];
      default = "wifi";
    };
  };

  config = mkIf cfg.enable {
    # https://github.com/termux/termux-packages/issues/1174
    environment.etc."resolv.conf".enable = false;
    environment.packages = [
      (pkgs.runCommand "resolvconf" { } ''
        mkdir -p $out/bin
        install -m 0755 ${./resolv-${cfg.implement}.sh} $out/bin/resolv
      '')
    ];
    hm.programs.zsh.initContent = ''
      resolv
    '';
  };
}
