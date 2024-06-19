{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption;
  cfg = config.my.lazyvim;
in
{
  options.my.lazyvim =
    let
      pluginsOptionType =
        with lib.types;
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
          bufferline-nvim
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          cmp_luasnip
          conform-nvim
          dashboard-nvim
          dressing-nvim
          flash-nvim
          friendly-snippets
          gitsigns-nvim
          indent-blankline-nvim
          lualine-nvim
          neo-tree-nvim
          neoconf-nvim
          neodev-nvim
          noice-nvim
          nui-nvim
          nvim-cmp
          nvim-lint
          nvim-lspconfig
          nvim-notify
          nvim-snippets
          nvim-spectre
          nvim-treesitter
          nvim-treesitter-textobjects
          nvim-ts-autotag
          nvim-ts-context-commentstring
          nvim-web-devicons
          persistence-nvim
          plenary-nvim
          telescope-fzf-native-nvim
          telescope-nvim
          todo-comments-nvim
          tokyonight-nvim
          trouble-nvim
          ts-comments-nvim
          vim-startuptime
          which-key-nvim
          {
            name = "LuaSnip";
            path = luasnip;
          }
          {
            name = "catppuccin";
            path = catppuccin-nvim;
          }
          {
            name = "mini.ai";
            path = mini-nvim;
          }
          {
            name = "mini.bufremove";
            path = mini-nvim;
          }
          {
            name = "mini.comment";
            path = mini-nvim;
          }
          {
            name = "mini.pairs";
            path = mini-nvim;
          }
        ];
      };

      extraPlugins = mkOption {
        type = pluginsOptionType;
        default = [ ];
      };

      excludePlugins = mkOption {
        type = pluginsOptionType;
        default = [ ];
      };

      extraSpec = mkOption {
        type = lib.types.lines;
        default = "";
      };
    };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      extraPackages = with pkgs; [
        # LazyVim
        lua-language-server
        stylua
        vscode-langservers-extracted
        # telescope
        ripgrep
      ];

      plugins = with pkgs.vimPlugins; [ lazy-nvim ];

      extraLuaConfig =
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
          lazyPath = pkgs.linkFarm "lazy-plugins" (
            builtins.map mkEntryFromDrv (lib.subtractLists cfg.excludePlugins cfg.plugins ++ cfg.extraPlugins)
          );
        in
        ''
          require("lazy").setup({
            defaults = {
              lazy = true,
            },
            dev = {
              path = "${lazyPath}",
              patterns = { "." },
              fallback = true,
            },
            spec = {
              { "LazyVim/LazyVim", import = "lazyvim.plugins" },
              -- The following configs are needed for fixing lazyvim on nix
              -- force enable telescope-fzf-native.nvim
              { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
              -- disable mason.nvim, use programs.neovim.extraPackages
              { "williamboman/mason-lspconfig.nvim", enabled = false },
              { "williamboman/mason.nvim", enabled = false },
              -- import/override with your plugins
              { import = "plugins" },
              -- treesitter handled by my.neovim.treesitterParsers, put this line at the end of spec to clear ensure_installed
              { "nvim-treesitter/nvim-treesitter", opts = function(_, opts) opts.ensure_installed = {} end },
          ${cfg.extraSpec}  },
          })
        '';
    };

    my.neovim.treesitterParsers =
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (
        plugins: with plugins; [
          c
          csv
          jsonc
          lua
          markdown
          markdown_inline
          regex
        ]
      )).dependencies;
  };
}
