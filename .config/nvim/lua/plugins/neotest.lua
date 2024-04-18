return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-jest",
	},
	config = function()
		local neotest = require("neotest")
		neotest.setup({
			adapters = {
				require("neotest-jest"),
			},
		})
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
		vim.keymap.set("n", "<leader>tb", neotest.summary.toggle, { desc = "[T]est [S]ummary" })
	end,
}
