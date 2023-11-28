local Util = require("lazyvim.util")
local map = vim.keymap.set

map("n", "<leader>fs", "<cmd>update<cr>", { desc = "Save file if modified" })
map("n", "<leader>fS", "<cmd>execute ':silent w !sudo tee % > /dev/null' | :edit!<cr>", { desc = "Sudo save" })

local lazyterm = function()
  Util.terminal(nil, { cwd = Util.root(), ctrl_hjkl = false })
end
map("n", "<leader>ft", lazyterm, { desc = "Terminal (root dir)" })
map("n", "<leader>fT", function()
  Util.terminal(nil, { ctrl_hjkl = false })
end, { desc = "Terminal (cwd)" })
map("n", "<c-/>", lazyterm, { desc = "Terminal (root dir)" })
