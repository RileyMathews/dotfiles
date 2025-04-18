return {
	"kevinhwang91/nvim-ufo",
	dependencies = "kevinhwang91/promise-async",
	config = function()
		local ufo = require("ufo")
		ufo.setup({
			provider_selector = function(bufnr, filetype, buftype)
				if filetype == "" then
					vim.notify("no filetype detected, setting ufo to indent")
					return { "indent" }
				end
				if buftype == "nofile" or filetype == "oil" or filetype == "snacks_dashboard" or filetype == "netrw" then
					return
				end
				return { "lsp", "treesitter" }
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
