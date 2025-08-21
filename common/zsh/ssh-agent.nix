{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.programs.zsh;
in
{
  options.programs.zsh.ssh-agent = {
    enable = mkEnableOption "programs.zsh.ssh-agent";
  };

  config = mkIf (cfg.enable && cfg.ssh-agent.enable) {
    programs.zsh.interactiveShellInit = ''
      # ssh-agent
      source "${./ssh-agent.sh}"
    '';
  };
}
