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
		{ import = "plugins" }
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

-- delete into the void
vim.keymap.set("n", "<leader>d", '"_d', { desc = "[D]elete into void" })
vim.keymap.set("v", "<leader>d", '"_d', { desc = "[D]elete into void" })

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

local spec_comment_lines = { "-- $> hspec spec", "" }
local spec_web_comment_lines = { "-- $> :import-spec-web", "", "-- $> hspecWithEnv spec", "" }

local function hspec_comment_exists()
	local search_result = vim.fn.search(spec_comment_lines[1])

	if search_result > 0 then
		return true
	end

	search_result = vim.fn.search(spec_web_comment_lines[1])

	if search_result > 0 then
		return true
	end

	return false
end


local function add_hspec_comments()
	local function add_hspec_comment(search_string, comment_lines)
		local search_result = vim.fn.search(search_string)

		if search_result > 0 then
			local existing_comments_result = vim.fn.search(comment_lines[1], "n")

			if existing_comments_result > 0 then
				return true
			end

			vim.api.nvim_buf_set_lines(0, search_result - 1, search_result - 1, true, comment_lines)
			vim.cmd.write()
			return true
		end
		return false
	end

	local has_spec_comment = add_hspec_comment(":: Spec$", spec_comment_lines)

	if not has_spec_comment then
		add_hspec_comment(":: SpecWeb$", spec_web_comment_lines)
	end
end

local function delete_hspec_comments()
	local function table_length(T)
		local count = 0
		for _ in pairs(T) do
			count = count + 1
		end
		return count
	end

	local function delete_hspec_comment(comment_lines)
		local num_lines = table_length(comment_lines)
		local search_result = vim.fn.search(comment_lines[1])

		if search_result > 0 then
			vim.api.nvim_buf_set_lines(0, search_result - 1, search_result + (num_lines - 1), true, {})
			vim.cmd.write()
		end
	end

	delete_hspec_comment(spec_comment_lines)
	delete_hspec_comment(spec_web_comment_lines)
end

local function toggle_hspec_comments()
	print("searching...")
	if hspec_comment_exists() then
		print("deleting...")
		delete_hspec_comments()
	else
		print("adding...")
		add_hspec_comments()
	end
end
local which_key = require("which-key")

which_key.add({
	{ "<leader>th", toggle_hspec_comments, name = "Add HSpec test eval comments", icon = { icon = "➕", hl = "" } },
	-- {
	-- 	"<leader>thd",
	-- 	delete_hspec_comments,
	-- 	name = "Delete HSpec test eval comments",
	-- 	icon = { icon = "✗", hl = "" },
	-- },
})
