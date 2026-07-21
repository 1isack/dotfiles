-- ~/.config/nvim/init.lua

-- Basic options
vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.wrap = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.termguicolors = true
vim.o.signcolumn = "yes"
vim.o.scrolloff = 8
vim.o.updatetime = 250
vim.o.clipboard = "unnamedplus"

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  install = { colorscheme = { "default" } },
  change_detection = { notify = false },
})

-- Basic keymaps
local map = vim.keymap.set
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
map("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", ":Telescope buffers<CR>", { desc = "Buffers" })

-- Pywal colorscheme (loaded last, after plugins have registered their highlight groups)
require("pywal").load()
