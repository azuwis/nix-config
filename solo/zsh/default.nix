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
    ".zshrc" = pkgs.runCommand "zsh-zshrc" { } ''
      substitute ${cfge.zshrc.source} $out --replace-fail /etc/zinputrc "${cfge.zinputrc.source}"
    '';
  };

  zsh = pkgs.wrapper {
    package = pkgs.zsh;
    env.ZDOTDIR = zdotdir;
    wrapperArgs = [ "--inherit-argv0" ];
  };

in
{
  config = lib.mkIf cfg.enable {
    environment.shell = zsh;
    environment.systemPackages = [ (lib.hiPrio zsh) ];
  };
}
