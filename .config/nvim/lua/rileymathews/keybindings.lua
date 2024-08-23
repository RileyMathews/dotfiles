-- misc rebinds
-- open neotree
vim.keymap.set("n", "<c-b>", "<cmd>Neotree toggle<cr>")

-- open oil
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>")

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

-- url-open
vim.keymap.set("n", "<leader>uo", "<esc>:URLOpenUnderCursor<cr>", { desc = "[U]rl [O]pen" })

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

-- -- document existing key chains
-- require("which-key").register({
--     { "<leader>c", group = "[C]ode" },
--     { "<leader>c_", hidden = true },
--     { "<leader>d", group = "[D]ocument" },
--     { "<leader>d_", hidden = true },
--     { "<leader>h", group = "[H]arpoon" },
--     { "<leader>h_", hidden = true },
--     { "<leader>r", group = "[R]ename" },
--     { "<leader>r_", hidden = true },
--     { "<leader>s", group = "[S]earch" },
--     { "<leader>s_", hidden = true },
--     { "<leader>t", group = "[T]est" },
--     { "<leader>t_", hidden = true },
--     { "<leader>u", group = "[U]rl" },
--     { "<leader>u_", hidden = true },
--     { "<leader>w", group = "[W]orkspace" },
--     { "<leader>w_", hidden = true },
-- })

vim.api.nvim_create_user_command("FormatDisable", function(args)
	if args.bang then
		-- FormatDisable! will disable formatting just for this buffer
		vim.b.disable_autoformat = true
		print("disabled autoformat for this buffer")
	else
		print("disabled autoformat for all buffers")
		vim.g.disable_autoformat = true
	end
end, {
	desc = "Disable autoformat-on-save",
	bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
	print("enabled autoformat for all buffers")
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, {
	desc = "Re-enable autoformat-on-save",
})

-- return the map with on attach function
return P
