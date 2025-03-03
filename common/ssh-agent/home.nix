{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.hm.shell) mkBashIntegrationOption mkZshIntegrationOption;
  cfg = config.my.ssh-agent;
  shellInit = ''
    # ssh-agent
    source "${./ssh-agent.sh}"
  '';
in
{
  options.my.ssh-agent = {
    enable = mkEnableOption "ssh-agent shell integration";
    enableBashIntegration = mkBashIntegrationOption { inherit config; };
    enableZshIntegration = mkZshIntegrationOption { inherit config; };
  };

  config = mkIf cfg.enable {
    programs.bash.initExtra = mkIf cfg.enableBashIntegration shellInit;
    programs.zsh.initExtra = mkIf cfg.enableZshIntegration shellInit;
  };
}
