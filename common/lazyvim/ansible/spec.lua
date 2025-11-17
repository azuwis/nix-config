return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        ansible = { "ansible-lint" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        ansible = { "ansible_lint" },
      },
    },
    init = function()
      vim.filetype.add({
        pattern = {
          [".*/playbooks/.*%.yaml"] = "yaml.ansible",
          [".*/playbooks/.*%.yml"] = "yaml.ansible",
          [".*/roles/.*/tasks/.*%.yaml"] = "yaml.ansible",
          [".*/roles/.*/tasks/.*%.yml"] = "yaml.ansible",
          [".*/roles/.*/handlers/.*%.yaml"] = "yaml.ansible",
          [".*/roles/.*/handlers/.*%.yml"] = "yaml.ansible",
        },
      })
    end,
  },
}
