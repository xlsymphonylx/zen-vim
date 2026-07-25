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

-- Diagnostics via Telescope, Enter jumps AND shows full error in float
vim.keymap.set("n", "<leader>ld", function()
  require("telescope.builtin").diagnostics({
    attach_mappings = function(_, map)
      map("i", "<CR>", function(prompt_bufnr)
        require("telescope.actions").select_default(prompt_bufnr)
        vim.schedule(function()
          vim.diagnostic.open_float({ scope = "cursor", wrap = true })
        end)
      end)
      return true
    end,
  })
end, { desc = "List all diagnostics" })
