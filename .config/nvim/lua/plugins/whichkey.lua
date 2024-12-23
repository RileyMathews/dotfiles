return {
	'folke/which-key.nvim',
	opts = {},
	event = 'BufWinEnter',
	config = function()
		local wk = require('which-key')
		wk.add({
			{ "<leader>l", "lsp" },
			{ "<leader>x", "trouble" },
			{ "<leader>h", "harpoon" },
			{ "<leader>s", "search" },
			{ "<leader>t", "test" },
			{ "<leader>t", "test" },
			{ "<leader>u", "url" },
		})
	end,
}
