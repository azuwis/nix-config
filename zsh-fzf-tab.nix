{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [( self: super: {
    zsh-fzf-tab = super.zsh-fzf-tab.overrideAttrs (o: rec {
      patches = [ ./pkgs/zsh-fzf-tab/darwin.patch ];
      meta.platforms = lib.platforms.unix;
    });
  })];

  home-manager.users."${config.my.user}" = { config, lib, pkgs, ... }: {
    home.packages = with pkgs; [
      zsh-fzf-tab
    ];

    programs.zsh = {
      initExtra = ''
        # zsh-fzf-tab
        . ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      '';
    };
  };
}
