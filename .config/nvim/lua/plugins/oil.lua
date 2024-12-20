return {
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			columns = { "icon" },
			view_options = {
				show_hidden = true,
			},
		},
		keys = { { "<leader>e", "<cmd>Oil --float<CR>", desc = "Toggle oil" } },
	},
}
