return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = {
    { "<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Horizontal terminal" },
    { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>", desc = "Vertical terminal" },
    { "<leader>tt", "<cmd>FloatingTerminal<CR>", desc = "Floating terminal" },
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

    -- Escape exits terminal mode to normal mode
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

    -- Persistent floating terminal (session stays alive on close)
    local float_term = require("toggleterm.terminal").Terminal:new({
      cmd = vim.o.shell,
      direction = "float",
      float_opts = {
        border = "rounded",
        width = 120,
        height = 40,
      },
    })

    vim.api.nvim_create_user_command("FloatingTerminal", function()
      float_term:toggle()
    end, {})

    vim.api.nvim_create_user_command("LazyGit", function()
      require("toggleterm.terminal").Terminal:new({
        cmd = "lazygit",
        direction = "float",
      }):toggle()
    end, {})
  end,
}
