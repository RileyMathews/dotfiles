local M = {}

M.format = function()
    vim.lsp.buf.format({ timeout_ms = 2000 })
end

return M
