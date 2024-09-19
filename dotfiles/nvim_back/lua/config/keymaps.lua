-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--Open an integrated terminal to run the python scripts
vim.api.nvim_set_keymap(
  "n",
  "<Leader>r",
  [[:15split | term /home/mike/anaconda3/bin/python %<CR>]],
  { noremap = true, silent = true }
)
-- Close current open tab
vim.api.nvim_set_keymap("n", "<Leader>tc", ":tabclose<CR>", { noremap = true, silent = true })
