require("custom.options")
require("custom.lazy_setup")
require("custom.keymaps")
require("custom.yank_highlight")
require("custom.hspec").setup()

vim.keymap.set("i", "<C-p>", function()
	require("blink-cmp").show()
end)
