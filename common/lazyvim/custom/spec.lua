return {
  { "echasnovski/mini.indentscope", enabled = false },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        component_separators = "",
        section_separators = { left = "", right = "" },
      },
    },
  },

  {
    "folke/neodev.nvim",
    optional = true,
    opts = {
      override = function(root_dir, library)
        if root_dir:find("/etc/nixos") == 1 or root_dir:find(".config/nixpkgs") then
          library.enabled = true
          library.plugins = true
        end
      end,
    },
  },
}
