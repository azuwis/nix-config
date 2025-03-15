local map = vim.keymap.set

map("n", "<leader>fs", "<cmd>update<cr>", { desc = "Save file if modified" })
map("n", "<leader>fq", "<cmd>wq<cr>", { desc = "Save and quit" })
map("n", "<leader>fS", "<cmd>execute ':silent w !sudo tee % > /dev/null' | :edit!<cr>", { desc = "Sudo save" })
