vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.wrap = false

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.g.mapleader = " "


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")
require("rileymathews")

vim.api.nvim_create_autocmd("Filetype", {
    pattern = "typescript",
    command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2",
})
-- treesitter parser does not handle ruby very well
-- this change is a bandaid that fixes an issue
-- where treesitter will outdent your code 
-- when typing a . on some occasions
vim.api.nvim_create_autocmd("Filetype", {
    pattern = "ruby",
    command = "setlocal indentkeys-=."
})
