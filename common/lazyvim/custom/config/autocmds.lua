local function lazyvim_augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

local function augroup(name)
  return vim.api.nvim_create_augroup("my_" .. name, { clear = true })
end

-- Disable spell for markdown by default, show lots of useless hints
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("no_spell"),
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "jjdescription", "NeogitCommitMessage" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("auto_insert"),
  pattern = { "jjdescription", "gitcommit", "NeogitCommitMessage" },
  command = "exec 'norm gg' | startinsert!",
})
