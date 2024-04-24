{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.zsh-fzf-tab;
in
{
  options.my.zsh-fzf-tab = {
    enable = mkEnableOption "zsh-fzf-tab";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.zsh-fzf-tab ];
    programs.zsh = {
      initExtra = ''
        # zsh-fzf-tab
        . ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      '';
    };
  };
}
