return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
	---@class avante.Config
	opts = {
		-- add any opts here
		-- for example
		provider = "ollama",
		auto_suggestions_provider = "ollama",
		copilot = {
			model = "claude-3.7-sonnet",
		},
		vendors = {
			["ollama"] = {
				__inherited_from = "openai",
				api_key_name = "",
				endpoint = "http://127.0.0.1:11434/v1",
				model = "llama3.1:8b",
				max_tokens = 32768,
			},
		},
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
