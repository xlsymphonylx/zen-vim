return {
  {
    "tomasr/molokai",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("molokai")
    end,
  },
  -- Keep kanagawa installed for switching via <leader>fc
  {
    "rebelot/kanagawa.nvim",
    name = "kanagawa",
    opts = {
      compile = true,
      theme = "wave",
      transparent = false,
      globalStatus = true,
      dimInactive = false,
      overrides = function(colors)
        return {
          NormalFloat = { bg = colors.theme.ui.bg_p1 },
          FloatBorder = { bg = colors.theme.ui.bg_p1 },
        }
      end,
    },
  },
}
