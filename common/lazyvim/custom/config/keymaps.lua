local map = vim.keymap.set

map("n", "<leader>fs", "<cmd>update<cr>", { desc = "Save file if modified" })
map("n", "<leader>fS", "<cmd>execute ':silent w !sudo tee % > /dev/null' | :edit!<cr>", { desc = "Sudo save" })
