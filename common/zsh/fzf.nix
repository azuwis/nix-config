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
  options.wrappers.zsh.fzf = {
    enable = mkEnableOption "wrappers.zsh.fzf";
  };

  config = mkIf (cfg.enable && cfg.fzf.enable) {
    environment.systemPackages = with pkgs; [
      fd
      fzf
    ];

    wrappers.zsh.interactiveShellInit = ''
      # fzf
      if [[ $options[zle] = on ]]; then
        eval "$(fzf --zsh)"
      fi
      export FZF_COMPLETION_TRIGGER='*'
      export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      _fzf_compgen_path() {
        fd --hidden --follow --exclude '.git' . "$1"
      }
      _fzf_compgen_dir() {
        fd --type d --hidden --follow --exclude '.git' . "$1"
      }
    '';
  };
}
