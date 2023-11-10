return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ansiblels = {},
      },
    },
    init = function()
      vim.filetype.add {
        pattern = {
          [".*/playbooks/.*%.yaml"] = "yaml.ansible",
          [".*/playbooks/.*%.yml"] = "yaml.ansible",
          [".*/roles/.*/tasks/.*%.yaml"] = "yaml.ansible",
          [".*/roles/.*/tasks/.*%.yml"] = "yaml.ansible",
          [".*/roles/.*/handlers/.*%.yaml"] = "yaml.ansible",
          [".*/roles/.*/handlers/.*%.yml"] = "yaml.ansible",
        },
      }
    end,
  },
}
