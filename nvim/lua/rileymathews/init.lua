vim.filetype.add({
    extension = {
        tera = "htmldjango",
    },
    pattern = {
        ["*/templates/**/*.html"] = "htmldjango"
    }
})
require("rileymathews.keybindings")
