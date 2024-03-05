-- misc rebinds
-- open neotree
vim.keymap.set("n", "<leader>e", "<cmd>Neotree<cr>", { desc = "[E]xplore files" })
vim.keymap.set("n", "<c-b>", "<cmd>Neotree toggle<cr>")

-- move lines up and down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")

-- half page jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- keep cursor in middle when searching
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- optional paste that does not put replaced text into buffer
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "[P]aste without replacing buffer" })

-- optional yank into system clipboard
vim.keymap.set("v", "<leader>y", '"+y', { desc = "[Y]ank into system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+Y', { desc = "[Y]ank into system clipboard" })

-- delete into the void
vim.keymap.set("n", "<leader>d", '"_d', { desc = "[D]elete into void" })
vim.keymap.set("v", "<leader>d", '"_d', { desc = "[D]elete into void" })

-- disable Q
vim.keymap.set("n", "Q", "<nop>")

-- make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file e[x]ecutable" })

-- linter hotkeys
vim.keymap.set("n", "<leader>ve", vim.diagnostic.open_float, { desc = "[V]iew [E]rror" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

-- harpoon
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>ha", mark.add_file, { desc = "[H]arpoon [A]dd file" })
vim.keymap.set("n", "<leader>ht", ui.toggle_quick_menu, { desc = "[H]arpoon [T]oggle" })

vim.keymap.set("n", "<leader>1", function()
    ui.nav_file(1)
end, { desc = "Harpoon file [1]" })
vim.keymap.set("n", "<leader>2", function()
    ui.nav_file(2)
end, { desc = "Harpoon file [2]" })
vim.keymap.set("n", "<leader>3", function()
    ui.nav_file(3)
end, { desc = "Harpoon file [3]" })
vim.keymap.set("n", "<leader>4", function()
    ui.nav_file(4)
end, { desc = "Harpoon file [4]" })

-- none ls
local custom = require("rileymathews.functions")
vim.keymap.set("n", "<leader>gf", custom.format, {})

-- tmux
vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>")
vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>")
vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>")
vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>")

-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set("n", "<leader>/", function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
    }))
end, { desc = "[/] Fuzzily search in current buffer" })

-- Also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set("n", "<leader>s/", function()
    builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
    })
end, { desc = "[S]earch [/] in Open Files" })

-- Shortcut for searching your neovim configuration files
vim.keymap.set("n", "<leader>sn", function()
    builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

-- document existing key chains
require("which-key").register({
    ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
    ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
    ["<leader>f"] = { name = "[F]ind", _ = "which_key_ignore" },
    ["<leader>v"] = { name = "[V]iew", _ = "which_key_ignore" },
    ["<leader>h"] = { name = "[H]arpoon", _ = "which_key_ignore" },
    ["<leader>g"] = { name = "[G]oto", _ = "which_key_ignore" },
    ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
})

-- return the map with on attach function
return P
