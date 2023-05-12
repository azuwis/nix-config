vim.opt.commentstring = "# %s"

vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = {"gitcommit", "NeogitCommitMessage"},
  command = "exec 'norm gg' | startinsert!",
})

if not vim.loop.fs_stat(vim.g.base46_cache) then
  require("base46").compile()
end
