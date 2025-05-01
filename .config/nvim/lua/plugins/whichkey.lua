return {
	"folke/which-key.nvim",
	opts = {},
	event = "BufWinEnter",
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>d", group = "[D]iagnostics" },
			{ "<leader>h", group = "[H]arpoon" },
			{ "<leader>f", group = "[F]ind" },
			{ "<leader>t", group = "[T]est" },
			{ "<leader>n", group = "[N]otifications" },
			{ "<leader>c", group = "[C]ode actions" },
			{ "<leader>j", group = "[J]ump (flash)" },
			{ "<leader>o", group = "C[o]pilot" },
		})
		for i = 1, 9 do
			wk.add({
				{ "<leader>" .. i, hidden = true },
			})
		end
	end,
}
