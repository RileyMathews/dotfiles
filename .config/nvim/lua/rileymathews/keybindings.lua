-- misc rebinds
-- open neotree
vim.keymap.set("n", "<c-b>", "<cmd>Neotree toggle<cr>")

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

-- linter hotkeys
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

-- harpoon
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "[H]arpoon [A]dd file" })
vim.keymap.set("n", "<leader>ht", ui.toggle_quick_menu, { desc = "[H]arpoon [T]oggle" })

vim.keymap.set("n", "<leader>1", function()
	ui.nav_file(1)
end, { desc = "Harpoon file [1]" })
vim.keymap.set("n", "<leader>2", function()
	ui.nav_file(2)
end, { desc = "Harpoon file [2]" })
vim.keymap.set("n", "<leader>3", function()
	ui.nav_file(3)
end, { desc = "Harpoon file [3]" })
vim.keymap.set("n", "<leader>4", function()
	ui.nav_file(4)
end, { desc = "Harpoon file [4]" })

-- tmux
vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>")
vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>")
vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>")
vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>")

vim.api.nvim_create_user_command("Vimtest", function()
	print("vim test activated")
	vim.keymap.set("n", "<leader>tn", ":TestNearest<CR>", { desc = "[T]est [N]earest" })
	vim.keymap.set("n", "<leader>tf", ":TestFile<CR>", { desc = "[T]est [F]ile" })
	vim.keymap.set("n", "<leader>ts", ":TestSuite<CR>", { desc = "[T]est [S]uite" })
	vim.keymap.set("n", "<leader>tl", ":TestLast<CR>", { desc = "[T]est [L]ast" })
end, {})

vim.api.nvim_create_user_command("Neotest", function()
	print("neotest activated")
	local neotest = require("neotest")
	vim.keymap.set("n", "<leader>tn", function()
		neotest.run.run()
	end, { desc = "[T]est [N]earest" })
	vim.keymap.set("n", "<leader>to", neotest.output.open, { desc = "[T]est [O]pen output" })
	vim.keymap.set("n", "<leader>tf", function()
		neotest.run.run(vim.fn.expand("%"))
	end, { desc = "[T]est [F]ile" })
	vim.keymap.set("n", "<leader>td", function()
		neotest.run.run({ strategy = "dap" })
	end, { desc = "[T]est [D]ebug" })
	vim.keymap.set("n", "<leader>ts", function()
		neotest.run.run({ suite = true })
	end, { desc = "[T]est [A]ll" })
	vim.keymap.set("n", "<leader>tl", neotest.run.run_last, { desc = "[T]est [A]ll" })
	vim.keymap.set("n", "<leader>tb", neotest.summary.toggle, { desc = "[T]est [B]reakdown" })
end, {})

-- document existing key chains
require("which-key").register({
	["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
	["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
	["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
	["<leader>h"] = { name = "[H]arpoon", _ = "which_key_ignore" },
	["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
	["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
	["<leader>t"] = { name = "[T]est", _ = "which_key_ignore" },
})

-- return the map with on attach function
return P
