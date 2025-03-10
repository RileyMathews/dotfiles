vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.wrap = false

vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50

vim.g.mapleader = " "
vim.g.db_ui_execute_on_save = 0
vim.cmd("autocmd BufEnter * set formatoptions-=cro")

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
require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
})
vim.filetype.add({
	extension = {
		tera = "htmldjango",
	},
})
vim.cmd.colorscheme("catppuccin")
vim.opt.showmode = false

-- misc rebinds
-- move lines up and down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- half page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep cursor in middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- optional paste that does not put replaced text into buffer
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "[P]aste without replacing buffer" })
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "[P]aste without replacing buffer" })

-- optional yank into system clipboard
vim.keymap.set("v", "<leader>y", '"+y', { desc = "[Y]ank into system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "[Y]ank into system clipboard" })

vim.keymap.set("n", "<leader>r", "<Plug>(DBUI_ExecuteQuery)", { desc = "[R]un SQL" })

-- disable Q
vim.keymap.set("n", "Q", "<nop>")

-- make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file e[x]ecutable" })

-- treesitter parser does not handle ruby very well
-- this change is a bandaid that fixes an issue
-- where treesitter will outdent your code
-- when typing a . on some occasions
vim.api.nvim_create_autocmd("Filetype", {
	pattern = "ruby",
	command = "setlocal indentkeys-=.",
})
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

local hspec_toggle = require("custom.hspec")
vim.keymap.set("n", "<leader>sh", hspec_toggle.toggle_hspec_comments, { desc = "Toggle [H]spec comments" })

vim.keymap.set("n", "<leader>tt", "<cmd>:tabnew<CR>", { desc = "[T]ab [T]ouch" })
vim.keymap.set("n", "<leader>tc", "<cmd>:tabclose<CR>", { desc = "[T]ab [C]lose" })
vim.keymap.set("n", "<leader>tn", "<cmd>:tabnext<CR>", { desc = "[T]ab [N]ext" })
vim.keymap.set("n", "<leader>tp", "<cmd>:tabprevious<CR>", { desc = "[T]ab [P]revious" })

vim.opt.guicursor = "n-v-c:block-Cursor/lCursor,i-ci-ve:ver25-Cursor2/lCursor2,r-cr:hor20,o:hor50"
vim.api.nvim_set_hl(0, "Cursor", { fg = "#cdd6f4", bg = "#6c7086" })
