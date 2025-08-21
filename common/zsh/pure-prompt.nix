{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.wrappers.zsh;
in
{
  options.wrappers.zsh.pure-prompt = {
    enable = mkEnableOption "wrappers.zsh.fzf";
  };

  config = mkIf (cfg.enable && cfg.pure-prompt.enable) {
    wrappers.zsh.promptInit = ''
      # pure-prompt
      . ${pkgs.pure-prompt}/share/zsh/site-functions/async
      . ${pkgs.pure-prompt}/share/zsh/site-functions/prompt_pure_setup
      PURE_GIT_PULL=0
      RPS1=""
    '';
  };
}
