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
		{ "<leader>sn", "<cmd>lua require('neotest').run.run()<CR>", desc = "[S]pec [N]earest" },
		{ "<leader>so", "<cmd>lua require('neotest').output.open()<CR>", desc = "[S]pec [O]pen output" },
		{ "<leader>sf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", desc = "[S]pec [F]ile" },
		{ "<leader>sd", "<cmd>lua require('neotest').run.run({ strategy = 'dap' })<CR>", desc = "[S]pec [D]ebug" },
		{ "<leader>ss", "<cmd>lua require('neotest').run.run({ suite = true })<CR>", desc = "[S]pec [A]ll" },
		{ "<leader>sl", "<cmd>lua require('neotest').run.run_last()<CR>", desc = "[S]pec [L]ast" },
		{ "<leader>sb", "<cmd>lua require('neotest').summary.toggle()<CR>", desc = "[S]pec [B]reakdown" },
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
