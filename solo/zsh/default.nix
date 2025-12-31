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
    ".zshrc" = pkgs.runCommand "zsh-zshrc" { preferLocalBuild = true; } ''
      substitute ${cfge.zshrc.source} $out --replace-fail /etc/zinputrc "${cfge.zinputrc.source}"
      sed -i '/^HOST=/d' $out
    '';
  };

  zsh = pkgs.wrapper {
    package = pkgs.zsh;
    # Need settting LOCALE_ARCHIVE before running for zsh locale support
    env.LOCALE_ARCHIVE = config.environment.variables.LOCALE_ARCHIVE;
    env.SHELL = "${placeholder "out"}/bin/zsh";
    env.ZDOTDIR = zdotdir;
    wrapper = pkgs.makeBinaryWrapper;
    wrapperArgs = [ "--inherit-argv0" ];
  };

in
{
  config = lib.mkIf cfg.enable {
    solo.shell = zsh;
  };
}
