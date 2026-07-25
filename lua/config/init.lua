require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")

-- Cheatsheet: <leader>? opens a curated keybinds window
vim.keymap.set("n", "<leader>?", require("config.cheatsheet"), { desc = "Open keybinds cheatsheet" })

-- Snippets: <leader>ss lists all available snippets for current filetype
vim.keymap.set("n", "<leader>ss", "<cmd>Ls<CR>", { desc = "List available snippets" })

-- Refresh SCSS class completion cache
vim.keymap.set("n", "<leader>sc", function()
  require("config.scss-completions").refresh()
  vim.notify("SCSS class cache refreshed", vim.log.levels.INFO)
end, { desc = "Refresh SCSS class cache" })

-- List all LSP diagnostics via Telescope
vim.keymap.set("n", "<leader>ld", function()
  require("telescope.builtin").diagnostics()
end, { desc = "List all diagnostics" })
