{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf mkOption;
  cfg = config.my.neovim;
in
{
  imports = [
    # ./nvchad
    ./lazyvim
    # ./update-nix-fetchgit
  ];

  options.my.neovim = {
    enable = mkEnableOption "neovim";

    treesitterParsers = mkOption { type = with lib.types; listOf package; };
  };

  config = mkIf cfg.enable {
    # Clear all caches
    # rm -rf ~/.cache/nvim/ ~/.local/share/nvim/lazy/ ~/.local/share/nvim/nvchad/
    # Clear old luac cache
    # find ~/.cache/nvim/luac -type f -mtime +1 -delete

    home.sessionVariables.EDITOR = "nvim";

    programs.neovim = {
      enable = true;
      withNodeJs = false;
      withRuby = false;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
    xdg.configFile."nvim/parser".source =
      let
        parsers = pkgs.symlinkJoin {
          name = "treesitter-parsers";
          paths = cfg.treesitterParsers;
        };
      in
      "${parsers}/parser";
  };
}
