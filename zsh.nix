{ config, pkgs, ... }:

{
  environment.pathsToLink = [ "/share/zsh" ];

  home-manager.users."${config.my.user}" = {
    home.packages = with pkgs; [
      pure-prompt
      zsh-fast-syntax-highlighting
      zsh-history-substring-search
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
        l = "ls -alh";
        ll = "ls -l";
      };
      initExtra = ''
        # Pure prompt
        . ${pkgs.pure-prompt}/share/zsh/site-functions/async
        . ${pkgs.pure-prompt}/share/zsh/site-functions/prompt_pure_setup
        PURE_GIT_PULL=0
        RPS1=""

        # Fast syntax highlight
        . ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh

        # History substring search
        . ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
        bindkey '^[OA' history-substring-search-up
        bindkey '^[OB' history-substring-search-down
        bindkey -M emacs '^P' history-substring-search-up
        bindkey -M emacs '^N' history-substring-search-down
        bindkey -M vicmd 'k' history-substring-search-up
        bindkey -M vicmd 'j' history-substring-search-down
      '';
    };
  };
}
