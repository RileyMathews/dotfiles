return {
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	config = function()
		local ufo = require("ufo")
		ufo.setup({
			provider_selector = function(bufnr, filetype, buftype)
				-- Return 'indent' if no filetype is detected
				if filetype == "" then
					vim.notify("No filetype detected, defaulting to 'indent' for folding.")
					return { "indent" }
				end

				-- Exclude certain buffer types or filetypes
				local excluded_buftypes = { "nofile" }
				local excluded_filetypes = { "oil", "snacks_dashboard", "netrw", "bigfile" }
				if vim.tbl_contains(excluded_buftypes, buftype) or vim.tbl_contains(excluded_filetypes, filetype) then
					return
				end

				local providers = {}

				-- Check for attached LSP clients
				local lsp_clients = vim.lsp.get_clients({ bufnr = bufnr })
				if lsp_clients and #lsp_clients > 0 then
					table.insert(providers, "lsp")
				end

				-- Check for available Tree-sitter parser
				local has_ts, parsers = pcall(require, "nvim-treesitter.parsers")
				if has_ts and parsers.has_parser(filetype) then
					table.insert(providers, "treesitter")
				end

				-- Always include 'indent' as a fallback
				table.insert(providers, "indent")

				-- Return the top two available providers
				local result = {}
				for i = 1, math.min(2, #providers) do
					table.insert(result, providers[i])
				end
				return result
			end,
		})

		vim.keymap.set("n", "zR", require("ufo").openAllFolds)
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

		vim.keymap.set("n", "zK", function()
			local winid = ufo.peekFoldedLinesUnderCursor()
			if not winid then
				vim.lsp.buf.hover()
			end
		end, { desc = "Peek Fold" })
	end,
}
