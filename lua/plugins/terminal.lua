return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    size = 15,
    open_mapping = false, -- we handle keybinds manually
    direction = "horizontal",
    hide_numbers = true,
    auto_scroll = true,
  },
  keys = {
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical terminal" },
  },
}
