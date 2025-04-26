return {
	"folke/which-key.nvim",
	opts = {},
	event = "BufWinEnter",
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>l", group = "lsp" },
			{ "<leader>d", group = "diagnostics" },
			{ "<leader>h", group = "harpoon" },
			{ "<leader>f", group = "find" },
			{ "<leader>s", group = "search" },
			{ "<leader>t", group = "test" },
			{ "<leader>n", group = "notifications" },
			{ "<leader>c", group = "copilot" },
			{ "<leader>g", group = "git" },
			{ "<leader>j", group = "flash" },
		})
		for i = 1, 9 do
			wk.add({
				{ "<leader>" .. i, hidden = true },
			})
		end
	end,
}
