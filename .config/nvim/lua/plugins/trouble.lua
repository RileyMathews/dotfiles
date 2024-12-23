return {
	"folke/trouble.nvim",
	opts = {}, -- for default options, refer to the configuration section for custom setup.
	cmd = "Trouble",
	keys = {
		{
			"<leader>xd",
			"<cmd>Trouble diagnostics toggle<cr>",
			desc = "Diagnostics",
		},
		{
			"<leader>xs",
			"<cmd>Trouble symbols toggle<cr>",
			desc = "Symbols",
		},
		{
			"<leader>xl",
			"<cmd>Trouble lsp toggle<cr>",
			desc = "LSP",
		},
	},
}
