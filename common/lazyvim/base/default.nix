{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption;
  cfg = config.programs.lazyvim;
in
{
  options.programs.lazyvim =
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
          # LazyVim uses nvim-treesitter's main branch
          # https://github.com/NixOS/nixpkgs/issues/415438
          (nvim-treesitter.overrideAttrs (old: {
            src = old.src.override {
              rev = "c5871d9d870c866fea9f271f1a3b3f29049a4793";
              sha256 = "sha256-oXHJxYFDqZ72C/sJGSMFVwkRRCXipVjE+xz+5eeCX30=";
            };
            postPatch = "";
            # `queries` moved to `runtime/queries` in main branch
            # Needed by `LazyVim.treesitter.have(ft, query)` -> `vim.treesitter.query.get(lang, query)`
            # https://github.com/LazyVim/LazyVim/blob/c64a61734fc9d45470a72603395c02137802bc6f/lua/lazyvim/plugins/treesitter.lua#L115
            # https://github.com/LazyVim/LazyVim/blob/c64a61734fc9d45470a72603395c02137802bc6f/lua/lazyvim/util/treesitter.lua#L23
            postInstall = ''
              ln -s $out/runtime/queries $out/queries
            '';
            nvimSkipModules = [ "nvim-treesitter._meta.parsers" ];
          }))
          (nvim-treesitter-textobjects.overrideAttrs (old: {
            src = old.src.override {
              rev = "227165aaeb07b567fb9c066f224816aa8f3ce63f";
              sha256 = "sha256-VUrpzaazSSo5KYJ/oOi2WH/QtpFDNFKs9CqqgO/tnmw=";
            };
          }))
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

    programs.lazyvim = {
      # vscode-langservers-extracted contains css/eslint/html/json/markdown language server,
      # but need nodejs, add 170M closure size
      extraPackages = with pkgs; [
        # LazyVim
        lua-language-server
        stylua
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
            map mkEntryFromDrv (lib.subtractLists cfg.excludePlugins cfg.plugins ++ cfg.extraPlugins)
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
        (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
          plugins = [ pkgs.vimPlugins.lazy-nvim ];
          viAlias = true;
          vimAlias = true;
          withRuby = false;
          luaRcContent = ''
            vim.g.lazyvim_check_order = false
            require("lazy").setup({
              defaults = {
                lazy = true,
              },
              dev = {
                path = "${lazyvimPlugins}",
                patterns = { "" },
                fallback = false,
              },
              rocks = {
                enabled = false,
              },
              spec = {
                { "LazyVim/LazyVim", import = "lazyvim.plugins" },
                -- The following configs are needed for fixing lazyvim on nix
                -- Disable mason.nvim, use programs.lazyvim.extraPackages
                { "mason-org/mason-lspconfig.nvim", enabled = false },
                { "mason-org/mason.nvim", enabled = false },
                -- import/override with your plugins
                { import = "plugins" },
                -- Treesitter parsers handled by programs.lazyvim.treesitterParsers,
                -- put this line at the end of spec to clear ensure_installed
                {
                  "nvim-treesitter/nvim-treesitter",
                  build = false,
                  opts = function(_, opts)
                    opts.ensure_installed = {}
                    -- Needed by `LazyVim.treesitter.have(ft)` -> `require("nvim-treesitter").get_installed("parsers")`
                    -- https://github.com/LazyVim/LazyVim/blob/c64a61734fc9d45470a72603395c02137802bc6f/lua/lazyvim/plugins/treesitter.lua#L105
                    -- https://github.com/LazyVim/LazyVim/blob/c64a61734fc9d45470a72603395c02137802bc6f/lua/lazyvim/util/treesitter.lua#L11
                    -- https://github.com/nvim-treesitter/nvim-treesitter/blob/c5871d9d870c866fea9f271f1a3b3f29049a4793/lua/nvim-treesitter/config.lua#L44
                    opts.install_dir = "${treesitterParsers}"
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
            doCheck = true;
            checkPhase = ''
              runHook preCheck

              lazy_plugins() {
                $out/bin/nvim -i NONE --headless -c ':lua for _, plugin in ipairs(require("lazy").plugins()) do if plugin.name ~= "lazy.nvim" then io.stdout:write(plugin.name .. "\n") end end' -c 'q' | sort
              }

              nix_plugins() {
                ls -1 "${lazyvimPlugins}" | sort
              }

              echo "Comparing plugins provided by Nix and required by LazyVim, should output nothing:"
              diff -u --label provided_by_nix <(nix_plugins) --label required_by_lazyvim <(lazy_plugins)

              runHook postCheck
            '';
            runtimeDeps = (old.runtimeDeps or [ ]) ++ cfg.extraPackages;
          });
    };
  };
}
