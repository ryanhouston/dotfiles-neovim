-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Force a global node version within neovim
vim.env.HNVM_NODE = "22.13.1"

-- Remap leader
vim.g.mapleader = ","

-- Set colorcolumn to indicate normal max line lengths
vim.opt.colorcolumn = "80,120"
