vim.opt.commentstring = "# %s"

vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = "gitcommit",
  command = "exec 'norm gg' | startinsert!",
})
