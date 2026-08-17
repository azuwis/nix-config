{
  config,
  lib,
  options,
  pkgs,
  ...
}:

let
  cfg = config.programs.zsh;
  cfge = config.environment.etc;

  zdotdir = pkgs.linkFarm "zsh-zdotdir" {
    ".zprofile" = cfge.zprofile.source;
    ".zshenv" = cfge.zshenv.source;
    ".zshrc" = pkgs.runCommandLocal "zsh-zshrc" { } ''
      substitute ${cfge.zshrc.source} $out --replace-fail /etc/zinputrc "${cfge.zinputrc.source}"
      sed -i '/^HOST=/d' $out
    '';
  };

  zsh = pkgs.wrapper {
    inherit (cfg) env;
    package = pkgs.zsh;
    wrapper = pkgs.makeBinaryWrapper;
    wrapperArgs = [ "--inherit-argv0" ];
  };

in
{
  options = {
    programs.zsh.env = lib.mkOption {
      default = { };
      inherit (options.environment.variables) type apply;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.env = {
      SHELL = "${placeholder "out"}/bin/zsh";
      ZDOTDIR = zdotdir;
    };
    solo.shell = zsh;
  };
}
