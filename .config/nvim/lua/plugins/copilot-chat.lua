if vim.env.NVIM_ENABLE_COPILOT == "true" then
	return {
		"CopilotC-Nvim/CopilotChat.nvim",
		build = "make tiktoken",
		opts = {
			model = "claude-3.7-sonnet-thought",
			mappings = {
				reset = {
					normal = "<leader>ox",
				},
			},
		},
		keys = {
			{
				"<leader>oa",
				function()
					local actions = require("CopilotChat.actions")
					require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
				end,
				desc = "C[o]pilotChat",
				mode = { "n", "v" },
			},
			{
				"<leader>ot",
				function()
					require("CopilotChat").toggle()
				end,
				desc = "C[o]pilotChat toggle",
				mode = { "n", "v" },
			},
		},
	}
else
	return {}
end
