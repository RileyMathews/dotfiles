return {
	"folke/which-key.nvim",
	opts = {},
	event = "BufWinEnter",
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>l", "lsp" },
			{ "<leader>x", "trouble" },
			{ "<leader>h", "harpoon" },
			{ "<leader>f", "find" },
			{ "<leader>s", "spec" },
			{ "<leader>t", "tabs" },
			{ "<leader>u", "url" },
			{ "<leader>n", "notifications" },
		})
		for i = 1, 9 do
			wk.add({
				{ "<leader>" .. i, hidden = true },
			})
		end
	end,
}
