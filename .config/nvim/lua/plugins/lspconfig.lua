return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					{ path = "snacks.nvim", words = { "Snacks" } },
				},
			},
		},
	},
	-- event = "BufReadPre",
	config = function()
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end)
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end)
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end
				map("<leader>ca", vim.lsp.buf.code_action, "[A]ction")
				map("<leader>cr", vim.lsp.buf.rename, "[R]ename")

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if client and client.server_capabilities.documentHighlightProvider then
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		local capabilities = vim.tbl_deep_extend(
			"force",
			require("blink.cmp").get_lsp_capabilities(),
			vim.lsp.protocol.make_client_capabilities(),
			-- following lines suggested by nvim ufo plugin for code folding
			{
				textDocument = {
					foldingRange = {
						dynamicRegistration = false,
						lineFoldingOnly = true,
					},
				},
			}
		)

		local servers = {
			lua_ls = {},
		}
		require("mason").setup()

		local ensure_installed = vim.tbl_keys(servers or {})
		vim.list_extend(ensure_installed, {
			"stylua", -- Used to format lua code
		})
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		local lspconfig = require("lspconfig")

		-- wire up servers that mason is managing for us
		require("mason-lspconfig").setup({
			function(server_name)
				vim.lsp.enable(server_name)
			end,
		})

		-- This bit is for servers not managed via mason
		local manual_servers = {
			hls = {
				cmd = { "static-ls", "--lsp" },
			},
			gdscript = {},
			-- I install djlsp via mason but have had trouble figuring out
			-- how to get it running automatically without also adding it here :(
			djlsp = {},
		}

		for server_name, server_settings in pairs(manual_servers) do
			server_settings.capabilities =
				vim.tbl_deep_extend("force", {}, capabilities, server_settings.capabilities or {})
			vim.lsp.config(server_name, server_settings)
			vim.lsp.enable(server_name)
		end
	end,
}
