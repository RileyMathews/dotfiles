return {
	"echasnovski/mini.nvim",
	config = function()
		require("mini.statusline").setup({
			use_icons = true,
		})
		vim.notify("loading move")
		require("mini.move").setup()
	end,
}
