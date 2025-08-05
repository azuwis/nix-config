{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    attrVals
    literalExpression
    mkEnableOption
    mkIf
    mkOption
    ;
  cfg = config.my.neovim;
in
{
  imports = [
    # ./nvchad
    # ./lazyvim
    # ./update-nix-fetchgit
  ];

  options.my.neovim = {
    enable = mkEnableOption "neovim";

    treesitterParsers = mkOption {
      default = [ ];
      example = literalExpression ''
        [ "nix" pkgs.vimPlugins.nvim-treesitter-parsers.yaml ]
      '';
      type =
        with lib.types;
        listOf (oneOf [
          str
          package
        ]);
    };
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
        parserStrings = builtins.filter builtins.isString cfg.treesitterParsers;
        parserPackages = builtins.filter lib.isDerivation cfg.treesitterParsers;
        parsers = pkgs.symlinkJoin {
          name = "treesitter-parsers";
          paths =
            (pkgs.vimPlugins.nvim-treesitter.withPlugins (
              plugins: attrVals parserStrings plugins ++ parserPackages
            )).dependencies;
        };
      in
      "${parsers}/parser";
  };
}
