return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        helm_ls = {},
      },
    },
  },

  {
    "towolf/vim-helm",
    ft = "helm",
  },
}
