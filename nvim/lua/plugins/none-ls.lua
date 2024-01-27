return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
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
                null_ls.builtins.formatting.rubocop,
                null_ls.builtins.diagnostics.rubocop,
			},

		})

        local function format()
            vim.lsp.buf.format({ timeout_ms = 2000 })
        end
	end,
}
