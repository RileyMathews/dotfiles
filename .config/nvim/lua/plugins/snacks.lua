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
				{
					icon = " ",
					title = "Recent Files",
					section = "recent_files",
					indent = 2,
					padding = 1,
					cwd = true,
				},
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
		picker = {
			hidden = true,
			cwd = vim.fn.getcwd(),
		},
	},
	keys = {
		{ "<leader>nh", "<cmd>lua Snacks.notifier.show_history()<CR>", desc = "History" },
		{ "<leader>nc", "<cmd>lua Snacks.notifier.hide()<CR>", desc = "clear" },
		{
			"<leader><space>",
			function()
				Snacks.picker.smart({ filter = { cwd = true } })
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader>f:",
			function()
				Snacks.picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>ns",
			function()
				Snacks.picker.notifications()
			end,
			desc = "Search Notification History",
		},
		-- {
		-- 	"<leader>e",
		-- 	function()
		-- 		Snacks.explorer()
		-- 	end,
		-- 	desc = "File Explorer",
		-- },
		-- find
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>ff",
			function()
				Snacks.picker.files({ hidden = true })
			end,
			desc = "Find Files",
		},
		-- Grep
		{
			"<leader>fG",
			function()
				Snacks.picker.grep_buffers()
			end,
			desc = "Grep Open Buffers",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep({ hidden = true })
			end,
			desc = "Grep",
		},
		{
			"<leader>fw",
			function()
				Snacks.picker.grep_word()
			end,
			desc = "Visual selection or word",
			mode = { "n", "x" },
		},
		-- search
		{
			"<leader>fC",
			function()
				Snacks.picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>fd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>fD",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
			desc = "Buffer Diagnostics",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help()
			end,
			desc = "Help Pages",
		},
		{
			"<leader>fi",
			function()
				Snacks.picker.icons()
			end,
			desc = "Icons",
		},
		{
			"<leader>fk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>fq",
			function()
				Snacks.picker.qflist()
			end,
			desc = "Quickfix List",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume",
		},
		{
			"<leader>fC",
			function()
				Snacks.picker.colorschemes()
			end,
			desc = "Colorschemes",
		},
		-- LSP
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"gI",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"gt",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Goto [T]ype Definition",
		},
	},
}
