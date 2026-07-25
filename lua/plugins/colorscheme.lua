return {
  "rebelot/kanagawa.nvim",
  name = "kanagawa",
  priority = 1000,
  opts = {
    compile = true,
    theme = "wave",        -- "wave" | "dragon" | "lotus"
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
  config = function(_, opts)
    require("kanagawa").setup(opts)
    vim.cmd.colorscheme("kanagawa")
  end,
}
