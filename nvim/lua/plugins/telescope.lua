return {
	'nvim-telescope/telescope.nvim', tag = '0.1.4',
	dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = '[P]roject [F]iles' })
        vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'project git files' })
        vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = '[P]project [S]earch' })
    end
}
