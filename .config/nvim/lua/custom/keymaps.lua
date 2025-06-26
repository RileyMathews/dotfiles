-- half page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep cursor in middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- optional paste that does not put replaced text into buffer
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "[P]aste without replacing buffer" })
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "[P]aste without replacing buffer" })

-- optional yank into system clipboard
vim.keymap.set("v", "<leader>y", '"+y', { desc = "[Y]ank into system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "[Y]ank into system clipboard" })

-- disable Q
vim.keymap.set("n", "Q", "<nop>")

-- These mappings control the size of splits (height/width)
vim.keymap.set("n", "<M-,>", "<c-w>5<")
vim.keymap.set("n", "<M-.>", "<c-w>5>")
vim.keymap.set("n", "<M-t>", "<C-W>+")
vim.keymap.set("n", "<M-s>", "<C-W>-")

vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end)
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end)
