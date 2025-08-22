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
  options.programs.zsh.fzf = {
    enable = mkEnableOption "programs.zsh.fzf";
  };

  config = mkIf (cfg.enable && cfg.fzf.enable) {
    environment.systemPackages = with pkgs; [
      fd
      fzf
    ];

    programs.zsh.interactiveShellInit = ''
      # fzf
      FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
      FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      _fzf_compgen_path() {
        fd --hidden --follow --exclude '.git' . "$1"
      }
      _fzf_compgen_dir() {
        fd --type d --hidden --follow --exclude '.git' . "$1"
      }
      if [[ $options[zle] = on ]]; then
        eval "$(fzf --zsh)"
      fi
    '';
  };
}
