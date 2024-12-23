return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-jest",
	},
	keys = {
		{ "<leader>tn", "<cmd>lua require('neotest').run.run()<CR>", desc = "Test nearest" },
		{ "<leader>to", "<cmd>lua require('neotest').output.open()<CR>", desc = "Test open output" },
		{ "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", desc = "Test file" },
		{ "<leader>td", "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<CR>", desc = "Test debug" },
		{ "<leader>ts", "<cmd>lua require('neotest').run.run({ suite = true })<CR>", desc = "Test all" },
		{ "<leader>tl", "<cmd>lua require('neotest').run.run_last()<CR>", desc = "Test last" },
		{ "<leader>tb", "<cmd>lua require('neotest').summary.toggle()<CR>", desc = "Test breakdown" },
	},
	config = function()
		local neotest = require("neotest")
		neotest.setup({
			adapters = {
				require("neotest-jest")({
					jest_test_discovery = false,
					env = {
						NODE_ENV = "test",
					},
				}),
			},
		})
	end,
}
