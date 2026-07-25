return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical terminal" },
    { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Lazygit (float)" },
  },
  config = function()
    require("toggleterm").setup({
      size = 15,
      open_mapping = false,
      direction = "horizontal",
      hide_numbers = true,
      auto_scroll = true,
    })

    vim.api.nvim_create_user_command("LazyGit", function()
      require("toggleterm.terminal").Terminal:new({
        cmd = "lazygit",
        direction = "float",
      }):toggle()
    end, {})
  end,
}
