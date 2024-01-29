-- misc rebinds
-- open neotree
vim.keymap.set("n", "<leader>e", "<cmd>Neotree<cr>", { desc = "[E]xplore files" })

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
vim.keymap.set("x", "<leader>p", "\"_dP", { desc = "[P]aste without replacing buffer" })

-- optional yank into system clipboard
vim.keymap.set("v", "<leader>y", "\"+y", { desc = "[Y]ank into system clipboard" })
vim.keymap.set("n", "<leader>Y", "\"+Y", { desc = "[Y]ank into system clipboard" })

-- delete into the void
vim.keymap.set("n", "<leader>d", "\"_d", { desc = "[D]elete into void" })
vim.keymap.set("v", "<leader>d", "\"_d", { desc = "[D]elete into void" })

-- disable Q
vim.keymap.set("n", "Q", "<nop>")

-- make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make file e[x]ecutable" })

-- linter hotkeys
vim.keymap.set('n', '<leader>ve', vim.diagnostic.open_float, { desc = "[V]iew [E]rror" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

-- harpoon
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set('n', "<leader>ha", mark.add_file, { desc = "[H]arpoon [A]dd file" })
vim.keymap.set('n', "<leader>ht", ui.toggle_quick_menu, { desc = "[H]arpoon [T]oggle" })

vim.keymap.set('n', '<leader>1', function() ui.nav_file(1) end, { desc = "Harpoon file [1]" })
vim.keymap.set('n', '<leader>2', function() ui.nav_file(2) end, { desc = "Harpoon file [2]" })
vim.keymap.set('n', '<leader>3', function() ui.nav_file(3) end, { desc = "Harpoon file [3]" })
vim.keymap.set('n', '<leader>4', function() ui.nav_file(4) end, { desc = "Harpoon file [4]" })

-- none ls
vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})

local telescope = require('telescope.builtin')
vim.keymap.set('n', '<c-p>', telescope.find_files)
vim.keymap.set('n', '<leader>ff', telescope.git_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = '[F]ind with [G]rep' })

-- tmux navigator
vim.keymap.set('n', '<c-h>', '<cmd>TmuxNavigateLeft<cr>')
vim.keymap.set('n', '<c-j>', '<cmd>TmuxNavigateDown<cr>')
vim.keymap.set('n', '<c-k>', '<cmd>TmuxNavigateUp<cr>')
vim.keymap.set('n', '<c-l>', '<cmd>TmuxNavigateRight<cr>')

-- lsp
-- create map with on attach function so it can be imported
-- and used in the lspconfig module. Otherwise these keybindings
-- would not get attached to buffers when the LSP attaches
local P = {}
P.on_attach = function(_, bufnr)
    local nmap = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto to [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto to [R]eferences')
    nmap('gi', require('telescope.builtin').lsp_implementations, '[G]oto to [I]mplementation')
    nmap('<leader>fs', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[F]ind [S]ymbols')

    nmap('<leader>vd', vim.lsp.buf.hover, '[V]iew [D]ocumentation')
    nmap('<leader>vs', vim.lsp.buf.signature_help, '[V]iew [S]ignature')
end
-- document existing key chains
require('which-key').register {
    ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
    ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
    ['<leader>f'] = { name = '[F]ind', _ = 'which_key_ignore' },
    ['<leader>v'] = { name = '[V]iew', _ = 'which_key_ignore' },
    ['<leader>h'] = { name = '[H]arpoon', _ = 'which_key_ignore' },
    ['<leader>g'] = { name = '[G]oto', _ = 'which_key_ignore' },
}

-- return the map with on attach function
return P
