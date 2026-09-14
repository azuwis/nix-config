vim.filetype.add({
  extension = {
    tf = "opentofu",
    tfvars = "opentofu-vars",
    tofu = "opentofu",
  },
})

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      vim.treesitter.language.register("terraform", "opentofu")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tofu_ls = {},
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        opentofu = { "tofu" },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        opentofu = { "tofu_fmt" },
        ["opentofu-vars"] = { "tofu_fmt" },
      },
    },
  },
}
