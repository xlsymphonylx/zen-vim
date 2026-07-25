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

-- Diagnostics via Telescope, press i to inspect full error in float
vim.keymap.set("n", "<leader>ld", function()
  require("telescope.builtin").diagnostics({
    attach_mappings = function(_, map)
      map("i", "i", function(prompt_bufnr)
        local entry = require("telescope.actions.state").get_selected_entry()
        if not entry then return end
        local bufnr = entry.bufnr or vim.fn.bufnr(entry.filename, false)
        vim.diagnostic.open_float({ bufnr = bufnr, scope = "line", wrap = true })
      end)
      return true
    end,
  })
end, { desc = "Diagnostics (i = inspect full error)" })
