return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		dashboard = {
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1, padding = 1 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
				{
					icon = " ",
					title = "Git Status",
					section = "terminal",
					enabled = function()
						return Snacks.git.get_root() ~= nil
					end,
					cmd = "git status --short --branch --renames",
					height = 5,
					padding = 1,
					ttl = 5 * 60,
					indent = 3,
				},
				{ section = "startup" },
			},
		},
		indent = {
			enabled = true,
			animate = {
				enabled = false,
			},
		},
		input = { enabled = true },
		notifier = {
			enabled = true,
			top_down = false,
			margin = { bottom = 1 },
		},
		quickfile = { enabled = true },
		scroll = { enabled = false },
		statuscolumn = { enabled = true },
		words = { enabled = true },
	},
	keys = {
		{ "<leader>nh", "<cmd>lua Snacks.notifier.show_history()<CR>", desc = "History" },
		{ "<leader>nc", "<cmd>lua Snacks.notifier.hide()<CR>", desc = "clear" },
	},
}
