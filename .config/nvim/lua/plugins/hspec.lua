return {
	dir = "~/code/ghciwatch-hspec-eval.nvim",
	config = function()
		local eval = require("ghciwatch-hspec-eval")

		vim.keymap.set("n", "<leader>th", eval.toggle_hspec_comments, { desc = "Toggle Hspec comments" })
	end
}
