vim.keymap.set("n", "<leader>fs", "<cmd>update<cr>", { desc = "Save file if modified" })
vim.keymap.set(
  "n",
  "<leader>fS",
  "<cmd>execute ':silent w !sudo tee % > /dev/null' | :edit!<cr>",
  { desc = "Sudo save" }
)
