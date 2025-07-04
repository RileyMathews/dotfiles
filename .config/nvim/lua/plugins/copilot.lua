if vim.env.NVIM_ENABLE_COPILOT == "true" then
	return {
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestgion = {
					enabled = true,
					auto_trigger = false,
					keymap = {
						next = "<M-n>",
					},
				},
			})

			local suggestion = require("copilot.suggestion")
			vim.keymap.set("i", "<M-n>", suggestion.next)
			vim.keymap.set("i", "<M-p>", suggestion.prev)
			vim.keymap.set("i", "<M-y>", suggestion.accept)
			vim.keymap.set("i", "<M-d>", suggestion.dismiss)
		end,
	}
else
	return {}
end
