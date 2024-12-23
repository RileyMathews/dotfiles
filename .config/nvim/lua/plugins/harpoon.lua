return {
	"ThePrimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local mark = require("harpoon.mark")
		local ui = require("harpoon.ui")

		vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "[H]arpoon [A]dd file" })
		vim.keymap.set("n", "<leader>ht", ui.toggle_quick_menu, { desc = "[H]arpoon [T]oggle" })
		for i = 1, 9 do
			vim.keymap.set("n", "<leader>" .. i, function()
				ui.nav_file(i)
			end, { desc = "Harpoon go to " .. i })
		end
	end,
}
