return {
	"folke/which-key.nvim",
	opts = {},
	event = "BufWinEnter",
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>l", group = "lsp" },
			{ "<leader>x", group = "trouble" },
			{ "<leader>h", group = "harpoon" },
			{ "<leader>f", group = "find" },
			{ "<leader>s", group = "search" },
			{ "<leader>t", group = "test" },
			{ "<leader>u", group = "url" },
			{ "<leader>n", group = "notifications" },
		})
		for i = 1, 9 do
			wk.add({
				{ "<leader>" .. i, hidden = true },
			})
		end
	end,
}
