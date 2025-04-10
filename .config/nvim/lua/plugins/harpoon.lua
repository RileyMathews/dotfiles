return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()
		vim.keymap.set("n", "<leader>ha", function()
			harpoon:list():add()
		end, { desc = "[H]arpoon [A]dd file" })
		vim.keymap.set("n", "<leader>ht", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "[H]arpoon [T]oggle" })
		for i = 1, 9 do
			vim.keymap.set("n", "<leader>" .. i, function()
				harpoon:list():select(i)
			end)
		end

		vim.keymap.set("n", "<A-h>", function()
			harpoon:list():select(1)
		end)
		vim.keymap.set("n", "<A-j>", function()
			harpoon:list():select(2)
		end)
		vim.keymap.set("n", "<A-k>", function()
			harpoon:list():select(3)
		end)
		vim.keymap.set("n", "<A-l>", function()
			harpoon:list():select(4)
		end)
	end,
}
