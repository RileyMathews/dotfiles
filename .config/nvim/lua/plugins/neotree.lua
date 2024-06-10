return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function ()
        local commands = require("neo-tree.command")
        require("neo-tree").setup({
            event_handlers = {
                {
                    event = "file_opened",
                    handler = function()
                        commands.execute({ action = 'close' })
                    end
                }
            },
            filesystem = {
                filtered_items = {
                    visible = true
                },
                follow_current_file = {
                    enabled = true,
                    leave_dirs_open = false,
                },
                hijack_netrw_behavior = "disabled",
            }
        })
    end
}
