return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { 
      enabled = true, 
      top_down = false, 
      margin = { bottom = 1 }, 
    },
    quickfile = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    { "<leader>nh", "<cmd>lua Snacks.notifier.show_history()<CR>", desc = "History" },
    { "<leader>nc", "<cmd>lua Snacks.notifier.hide()<CR>", desc = "clear" },
  }
}
