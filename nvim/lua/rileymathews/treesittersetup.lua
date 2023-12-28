vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'html', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },

    highlight = { enable = true },
    indent = { enable = true },
  }
end, 0)
