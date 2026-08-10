{
  config,
  lib,
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
    package = pkgs.zsh;
    env = {
      # Need settting LOCALE_ARCHIVE before running for zsh locale support
      LOCALE_ARCHIVE = config.environment.variables.LOCALE_ARCHIVE;
      SHELL = "${placeholder "out"}/bin/zsh";
      ZDOTDIR = zdotdir;
    }
    # Infinite recursion if `environment.variables.DIRENV_CONFIG = "${config.system.build.etc}/etc/direnv"`
    // lib.optionalAttrs config.programs.direnv.enable {
      DIRENV_CONFIG = "${config.system.build.etc}/etc/direnv";
    };
    wrapper = pkgs.makeBinaryWrapper;
    wrapperArgs = [ "--inherit-argv0" ];
  };

in
{
  config = lib.mkIf cfg.enable {
    solo.shell = zsh;
  };
}
