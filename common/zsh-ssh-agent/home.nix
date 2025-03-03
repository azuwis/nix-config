{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.zsh-ssh-agent;
  shellInit = ./start_ssh_agent.sh;
in
{
  options.my.zsh-ssh-agent = {
    enable = mkEnableOption "zsh-ssh-agent";
  };

  config = mkIf cfg.enable {
    programs.zsh.initExtra = ''
      source "${shellInit}"
    '';
  };
}
