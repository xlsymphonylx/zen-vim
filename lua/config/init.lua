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

-- Toggle diagnostics location list
vim.keymap.set("n", "<leader>ld", function()
  -- Check if a location list window is already open
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local info = vim.fn.getwininfo(win)
    if #info > 0 and info[1].loclist == 1 then
      vim.cmd("lclose")
      return
    end
  end
  vim.diagnostic.setloclist({ open = true })
end, { desc = "Toggle diagnostics list" })

-- In location/quickfix lists, make Enter jump AND show the diagnostic float
vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.keymap.set("n", "<CR>", function()
      vim.cmd(".cc")
      vim.diagnostic.open_float({ scope = "line" })
    end, { buffer = true, silent = true, desc = "Jump and show diagnostic" })
  end,
})
