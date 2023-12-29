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
			},
		})

		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
	end,
}
