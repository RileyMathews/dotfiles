return {
	'nvim-telescope/telescope.nvim', tag = '0.1.4',
	dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>sg', builtin.git_files, { desc = '[S]search [G]it files' })
        vim.keymap.set('n', '<leader>gs', builtin.live_grep, { desc = '[G]rep [S]earch' })
    end
}
