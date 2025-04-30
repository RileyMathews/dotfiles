return {
	"saghen/blink.cmp",
	version = "1.*",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	dependencies = {
		"saghen/blink.compat",
		"MattiasMTS/cmp-dbee",
	},
	opts = {
		keymap = { preset = "default" },

		appearance = {
			nerd_font_variant = "mono",
		},

		completion = { documentation = { auto_show = true } },
		fuzzy = { implementation = "prefer_rust_with_warning" },
		sources = {
			default = { "lsp", "path", "buffer" },
			per_filetype = {
				sql = { "dadbod", "buffer" },
			},
			-- add vim-dadbod-completion to your completion providers
			providers = {
				dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
			},
		},
	},
	opts_extend = { "sources.default" },
}
