return {
	-- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
		"RRethy/nvim-treesitter-endwise",
		-- "windwp/nvim-ts-autotag",
		-- "windwp/nvim-autopairs",
	},
	build = ":TSUpdate",
	event = "BufRead",
	config = function()
		require("nvim-treesitter.configs").setup({
			auto_install = true,
			highlight = {
				enable = true,
				disable = function(_, buf)
					local max_filesize = 100 * 1024 -- 100 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,
			},
			indent = { enable = true },
			endwise = { enable = true },
		})
		-- require("nvim-ts-autotag").setup()
		-- require("nvim-autopairs").setup()
	end,
}
