local uv = vim.uv

-- local dir
-- if uv.fs_stat("/etc/nixos") then
--   dir = "/etc/nixos"
-- else
--   dir = vim.fn.expand("~/.config/nixpkgs")
-- end

return {
  -- nixd used to give `nixd: %-32001:` error
  -- {
  --   "folke/noice.nvim",
  --   optional = true,
  --   opts = {
  --     routes = {
  --       {
  --         filter = {
  --           event = "notify",
  --           error = true,
  --           find = "nixd: %-32001:",
  --         },
  --         opts = { skip = true },
  --       },
  --     },
  --   },
  -- },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nixd = {
          settings = {
            nixd = {
              formatting = {
                command = { "nixfmt" },
              },
              -- Disable for now, use lots of memory, the default exprs shoud be enough
              -- https://github.com/nix-community/nixd/blob/065dcb4cb2f8269d6d15d2b2491a79cff47f9550/nixd/lib/Controller/LifeTime.cpp#L26-L37
              -- options = {
              --   nixos = {
              --     expr = string.format("(import %s { }).nixosConfigurations.nuc.options", dir),
              --   },
              --   ["nix-darwin"] = {
              --     expr = string.format("(import %s { }).darwinConfigurations.mbp.options", dir),
              --   },
              -- },
            },
          },
        },
      },
    },
  },
}
