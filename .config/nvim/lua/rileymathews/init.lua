vim.filetype.add({
	extension = {
		tera = "htmldjango",
	},
})
vim.cmd.colorscheme("catppuccin")
vim.opt.showmode = false
require("rileymathews.keybindings")
