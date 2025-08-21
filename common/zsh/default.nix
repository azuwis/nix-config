{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./fzf.nix
    ./pure-prompt.nix
    ./zoxide.nix
  ];

  environment.systemPackages = with pkgs; [
    zsh-completions
  ];

  programs.zsh = {
    histSize = 10000;

    setOptions = [
      "EXTENDED_HISTORY"
      "HIST_FCNTL_LOCK"
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_SPACE"
      "INC_APPEND_HISTORY"
      "SHARE_HISTORY"
    ];

    shellAliases = {
      cr = ''cd "$(git rev-parse --show-toplevel)"'';
      l = "ls --color=auto -l";
      ls = "ls --color=auto";
      nix-build = "nix-build --log-format bar-with-logs";
      nix-shell = "nix-shell --log-format bar-with-logs";
    };

    interactiveShellInit = ''
      ulimit -n 4096
      bindkey -e
      zstyle ':completion:*' matcher-list "" 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      # setopt MENU_COMPLETE

      # zsh-autosuggestions
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      ZSH_AUTOSUGGEST_STRATEGY=(history)

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
}
