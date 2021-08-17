{ config, lib, pkgs, ... }:

{
  environment.pathsToLink = [ "/share/zsh" ];

  home-manager.users."${config.my.user}" = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      fd
      pure-prompt
      zsh-completions
      zsh-fast-syntax-highlighting
      zsh-history-substring-search
      zsh-nix-shell
    ];

    programs.fzf.enable = true;
    programs.zoxide.enable = true;
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      defaultKeymap = "emacs";
      history.extended = true;
      shellAliases = {
        l = "ls --color=auto -l";
        ls = "ls --color=auto";
      };
      initExtra = ''
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
        ulimit -n 2048

        # fzf
        export FZF_COMPLETION_TRIGGER='*'
        export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        _fzf_compgen_path() {
          fd --hidden --follow --exclude '.git' . "$1"
        }
        _fzf_compgen_dir() {
          fd --type d --hidden --follow --exclude '.git' . "$1"
        }

        # pure-prompt
        . ${pkgs.pure-prompt}/share/zsh/site-functions/async
        . ${pkgs.pure-prompt}/share/zsh/site-functions/prompt_pure_setup
        PURE_GIT_PULL=0
        RPS1=""

        # zsh-fast-syntax-highlighting
        . ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh

        # zsh-history-substring-search
        . ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
        bindkey '^[OA' history-substring-search-up
        bindkey '^[OB' history-substring-search-down
        bindkey -M emacs '^P' history-substring-search-up
        bindkey -M emacs '^N' history-substring-search-down
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down

        # zsh-nix-shell
        . ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
      '';
    };
  };
}
