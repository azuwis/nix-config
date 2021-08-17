{ config, lib, pkgs, ... }:

{
  environment.pathsToLink = [ "/share/zsh" ];

  home-manager.users."${config.my.user}" = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
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
        l = "ls --color -l";
        ls = "ls --color";
      };
      initExtra = ''
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'm:{a-zA-Z}={A-Za-z} l:|=* r:|=*'
        ulimit -n 2048

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
