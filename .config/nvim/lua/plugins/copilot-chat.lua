return {
	"CopilotC-Nvim/CopilotChat.nvim",
	build = "make tiktoken",
	opts = {
		model = "claude-3.7-sonnet-thought",
		mappings = {
			reset = {
				normal = "<leader>cx"
			}
		}
	},
	keys = {
		{
			"<leader>ca",
			function()
				local actions = require("CopilotChat.actions")
				require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
			end,
			desc = "CopilotChat",
			mode = { "n", "v" },
		},
		{
			"<leader>cc",
			function()
				require("CopilotChat").toggle()
			end,
			desc = "CopilotChat toggle",
			mode = { "n", "v" },
		},
	},
}
