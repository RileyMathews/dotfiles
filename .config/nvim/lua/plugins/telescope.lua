return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.4",
	dependencies = { "nvim-lua/plenary.nvim" },
	opts = {
		pickers = {
			find_files = {
				hidden = true,
				file_ignore_patterns = { "%.git/", "%.hg/", "%.svn/", "%.idea/", "%.vscode/", "%.DS_Store" },
			},
		},
	},
}
