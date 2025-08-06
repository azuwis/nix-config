{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption;
  cfg = config.wrappers.lazyvim;
in
{
  options.wrappers.lazyvim =
    let
      pluginsOptionType =
        let
          inherit (lib.types)
            listOf
            oneOf
            package
            str
            submodule
            ;
        in
        listOf (oneOf [
          package
          (submodule {
            options = {
              name = mkOption { type = str; };
              path = mkOption { type = package; };
            };
          })
        ]);
    in
    {
      enable = mkEnableOption "LazyVim";

      plugins = mkOption {
        type = pluginsOptionType;
        default = with pkgs.vimPlugins; [
          LazyVim
          blink-cmp
          bufferline-nvim
          conform-nvim
          flash-nvim
          friendly-snippets
          fzf-lua
          gitsigns-nvim
          grug-far-nvim
          lazydev-nvim
          lualine-nvim
          neo-tree-nvim
          noice-nvim
          nui-nvim
          nvim-lint
          nvim-lspconfig
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-ts-autotag
          persistence-nvim
          plenary-nvim
          snacks-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          ts-comments-nvim
          which-key-nvim
          {
            name = "catppuccin";
            path = catppuccin-nvim;
          }
          {
            name = "mini.ai";
            path = mini-nvim;
          }
          {
            name = "mini.icons";
            path = mini-nvim;
          }
          {
            name = "mini.pairs";
            path = mini-nvim;
          }
        ];
      };

      extraPackages = mkOption {
        default = [ ];
        example = lib.literalExpression ''
          [ pkgs.ripgrep ]
        '';
        type = with lib.types; listOf package;
      };

      extraPlugins = mkOption {
        type = pluginsOptionType;
        default = [ ];
      };

      excludePlugins = mkOption {
        type = pluginsOptionType;
        default = [ ];
      };

      finalPackage = mkOption {
        type = lib.types.package;
        readOnly = true;
      };

      config = mkOption {
        type = with lib.types; attrsOf path;
        default = { };
      };

      treesitterParsers = mkOption {
        default = [ ];
        example = lib.literalExpression ''
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

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.finalPackage ];
    environment.variables.EDITOR = "nvim";

    wrappers.lazyvim = {
      extraPackages = with pkgs; [
        # LazyVim
        lua-language-server
        stylua
        vscode-langservers-extracted
        # fzf-lua
        fd
        fzf
        ripgrep
      ];

      treesitterParsers = [
        "csv"
        "jsonc"
        "regex"
      ];

      finalPackage =
        (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
          plugins = [ pkgs.vimPlugins.lazy-nvim ];
          viAlias = true;
          vimAlias = true;
          withRuby = false;
          luaRcContent =
            let
              mkEntryFromDrv =
                drv:
                if lib.isDerivation drv then
                  {
                    name = "${lib.getName drv}";
                    path = drv;
                  }
                else
                  drv;
              lazyvimPlugins = pkgs.linkFarm "lazyvim-plugins" (
                builtins.map mkEntryFromDrv (lib.subtractLists cfg.excludePlugins cfg.plugins ++ cfg.extraPlugins)
              );
              lazyvimConfig = pkgs.linkFarm "lazyvim-config" (
                lib.mapAttrsToList (name: value: {
                  name = if (lib.hasSuffix ".lua" value) then "lua/plugins/${name}.lua" else name;
                  path = value;
                }) cfg.config
              );
              treesitterParsers = pkgs.symlinkJoin {
                name = "treesitter-parsers";
                paths =
                  let
                    parserStrings = builtins.filter builtins.isString cfg.treesitterParsers;
                    parserPackages = builtins.filter lib.isDerivation cfg.treesitterParsers;
                  in
                  (pkgs.vimPlugins.nvim-treesitter.withPlugins (
                    plugins: lib.attrVals parserStrings plugins ++ parserPackages
                  )).dependencies;
              };
            in
            ''
              vim.g.lazyvim_check_order = false
              require("lazy").setup({
                defaults = {
                  lazy = true,
                },
                dev = {
                  path = "${lazyvimPlugins}",
                  patterns = { "" },
                  fallback = true,
                },
                rocks = {
                  enabled = false,
                },
                spec = {
                  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
                  -- The following configs are needed for fixing lazyvim on nix
                  -- Disable mason.nvim, use wrappers.lazyvim.extraPackages
                  { "williamboman/mason-lspconfig.nvim", enabled = false },
                  { "williamboman/mason.nvim", enabled = false },
                  -- import/override with your plugins
                  { import = "plugins" },
                  -- Treesitter parsers handled by wrappers.lazyvim.treesitterParsers,
                  -- put this line at the end of spec to clear ensure_installed
                  {
                    "nvim-treesitter/nvim-treesitter",
                    opts = function(_, opts)
                      opts.ensure_installed = {}
                    end,
                  },
                },
                performance = {
                  rtp = {
                    -- Needed for [lazyvim config](https://www.lazyvim.org/configuration/general)
                    -- and treesitter parsers
                    paths = {
                      "${lazyvimConfig}",
                      "${treesitterParsers}",
                    },
                  },
                },
              })
            '';
        }).overrideAttrs
          (old: {
            runtimeDeps = (old.runtimeDeps or [ ]) ++ cfg.extraPackages;
          });
    };
  };
}
