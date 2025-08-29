require("custom.options")
require("custom.lazy_setup")
require("custom.keymaps")
require("custom.yank_highlight")
require("custom.hspec").setup()
require("custom.auto_commands")

local ghciwatch = require("custom.ghciwatch").setup()
local conform = require("conform")
local trouble = require("trouble")

vim.keymap.set("n", "<leader>gs", ghciwatch.initialize)
vim.keymap.set("n", "<leader>gk", ghciwatch.deinitialize)
vim.keymap.set("n", "<leader>gw", ghciwatch.show_buffer)
vim.keymap.set("n", "<F1>", "<Nop>")
vim.keymap.set("i", "<F1>", "<Nop>")
vim.keymap.set("n", "<leader>cf", function()
	conform.format({ timeout_ms = 3000 })
end, { desc = "[F]ormat" })

vim.keymap.set("n", "<leader>dn", function()
	trouble.next(trouble.Window, {skip_groups = true, jump = true});
end)
vim.keymap.set("n", "<leader>dp", function()
	trouble.prev(trouble.Window, {skip_groups = true, jump = true});
end)
