local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require("lspconfig")
local servers = {
  "ansiblels",
  "lua_ls",
  "nil_ls",
  "terraformls",
  "yamlls",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = on_attach,
    capabilities = capabilities,
  })
end

lspconfig.lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      -- workspace = {
      --   library = vim.api.nvim_get_runtime_file("", true),
      --   checkThirdParty = false,
      -- },
      telemetry = {
        enable = false,
      },
    },
  },
})

lspconfig.yamlls.setup({
  settings = {
    yaml = {
      keyOrdering = false,
    },
  },
})
