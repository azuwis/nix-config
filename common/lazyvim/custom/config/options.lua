vim.g.bigfile_size = 1024 * 500
vim.opt.diffopt:remove("linematch:40")
vim.opt.diffopt:append({
  "algorithm:histogram",
  "indent-heuristic",
  "linematch:60",
})
