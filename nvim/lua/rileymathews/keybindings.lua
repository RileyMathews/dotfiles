-- misc rebinds
-- open neotree
vim.keymap.set("n", "<leader>e", "<cmd>Neotree<cr>")

-- half page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep cursor in middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- optional paste that does not put replaced text into buffer
vim.keymap.set("x", "<leader>p", "\"_dP")

-- optional yank into system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- delete into the void
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- disable Q
vim.keymap.set("n", "Q", "<nop>")

-- make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>")

-- linter hotkeys
vim.keymap.set('n', '<leader>pe', vim.diagnostic.open_float, { desc = "[P]eek [E]rror" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- harpoon
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set('n', "<leader>ha", mark.add_file, { desc = "[H]arpoon [A]dd file" })
vim.keymap.set('n', "<leader>ht", ui.toggle_quick_menu, { desc = "[H]arpoon [T]oggle" })

vim.keymap.set('n', '<leader>1', function() ui.nav_file(1) end, { desc = "Harpoon file [1]" })
vim.keymap.set('n', '<leader>2', function() ui.nav_file(2) end, { desc = "Harpoon file [2]" })
vim.keymap.set('n', '<leader>3', function() ui.nav_file(3) end, { desc = "Harpoon file [3]" })
vim.keymap.set('n', '<leader>4', function() ui.nav_file(4) end, { desc = "Harpoon file [4]" })
require('which-key').register {
    ['<leader>h'] = { name = '[H]arpoon', _ = 'which_key_ignore' },
}
