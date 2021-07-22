{ config, pkgs, ... }:

{
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  environment.pathsToLink = [ "/share/zsh" ];

  home-manager.users."${config.my.user}" = {
    home.packages = with pkgs; [
      pure-prompt
      zsh-fast-syntax-highlighting
      zsh-history-substring-search
    ];

    # Git
    programs.git = {
      enable = true;
      userEmail = config.my.email;
      userName = config.my.name;
      aliases = {
        ci = "commit";
        cp = "cherry-pick";
        fixup = "!sh -c 'git commit --fixup=$1 && git rebase --interactive --autosquash $1~' -";
        lg = "log --abbrev-commit --graph --date=relative --pretty=format:'%C(yellow)%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset'";
        st = "status";
      };
    };

    # Vim
    programs.vim = {
      enable = true;
      plugins = with pkgs.vimPlugins; [
        lightline-vim
        vim-nix
      ];
      extraConfig = ''
        set noshowmode
        let g:lightline = {
          \ 'colorscheme': 'seoul256',
          \ }
      '';
    };

    # Zsh
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
