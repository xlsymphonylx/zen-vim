require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

-- Cheatsheet: <leader>? opens a curated keybinds window
vim.keymap.set("n", "<leader>?", require("config.cheatsheet"), { desc = "Open keybinds cheatsheet" })

-- Snippets: <leader>ss lists all available snippets for current filetype
vim.keymap.set("n", "<leader>ss", "<cmd>Ls<CR>", { desc = "List available snippets" })
