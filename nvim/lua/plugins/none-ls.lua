return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		local h = require("null-ls.helpers")
		local methods = require("null-ls.methods")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				null_ls.builtins.diagnostics.ruff,
				null_ls.builtins.formatting.ruff,
				null_ls.builtins.formatting.ruff_format,
				null_ls.builtins.diagnostics.djlint,
				null_ls.builtins.formatting.djlint,
				null_ls.builtins.formatting.prettier,
				null_ls.builtins.formatting.erb_lint,
				null_ls.builtins.diagnostics.rubocop,
				h.make_builtin({
					name = "rubocop",
					meta = {
						url = "https://github.com/rubocop/rubocop",
						description = "Ruby static code analyzer and formatter, based on the community Ruby style guide.",
					},
					method = methods.internal.FORMATTING,
					filetypes = { "ruby" },
					generator_opts = {
						command = "rubocop",
						args = {
							-- NOTE: For backwards compatibility,
							-- we are still using "-a" shorthand' for both "--auto-correct" (pre-1.3.0) and "--autocorrect" (1.3.0+).
							"-A",
							"--server",
							"-f",
							"quiet",
							"--stderr",
							"--stdin",
							"$FILENAME",
						},
						to_stdin = true,
					},
					factory = h.formatter_factory,
				}),
			},
		})
	end,
}
