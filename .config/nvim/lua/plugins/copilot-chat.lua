return {
	"CopilotC-Nvim/CopilotChat.nvim",
	build = "make tiktoken",
	opts = {
		model = "claude-3.7-sonnet-thought",
	},
	keys = {
		{
			"<leader>cc",
			function()
				local actions = require("CopilotChat.actions")
				require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
			end,
			desc = "CopilotChat",
			mode = { "n", "v" },
		},
	},
}
