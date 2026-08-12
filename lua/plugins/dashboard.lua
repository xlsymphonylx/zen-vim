return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- ── Header (dharmachakra) ──
    dashboard.section.header.val = {
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⠟⠹⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⣷⣦⣄⣠⣿⠃⢠⣄⠈⢻⣆⣠⣴⡞⡆⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⢀⣀⣀⣿⠀⠈⢻⣇⢀⣾⢟⡄⣸⡿⠋⠀⡇⣇⣀⣀⠀⠀⠀⠀⠀",
      "⠀⣤⣤⣤⣀⣱⢻⠚⠻⣧⣀⠀⢹⡿⠃⠈⢻⣟⠀⢀⣤⠧⠓⣹⣟⣀⣤⣤⣤⡀",
      "⠀⠈⠻⣧⠉⠛⣽⠀⠀⠀⠙⣷⡿⠁⠀⠀⠀⢻⣶⠛⠁⠀⠀⡟⠟⠉⣵⡟⠁⠀",
      "⠀⠀⠀⠹⣧⡀⠏⡇⠀⠀⠀⣿⠁⠀⠀⠀⠀⠀⣿⡄⠀⠀⢠⢷⠀⣼⡟⠀⠀⠀",
      "⠀⠀⠀⠀⠙⣟⢼⡹⡄⠀⠀⣿⡄⠀⠀⠀⠀⢀⣿⡇⠀⢀⣞⣦⢾⠟⠀⠀⠀⠀",
      "⠀⠠⢶⣿⣛⠛⢒⣭⢻⣶⣤⣹⣿⣤⣀⣀⣠⣾⣟⣠⣔⡛⢫⣐⠛⢛⣻⣶⠆⠀",
      "⠀⠀⠀⠉⣻⡽⠛⠉⠁⠀⠉⢙⣿⠖⠒⠛⠻⣿⡋⠉⠁⠈⠉⠙⢿⣿⠉⠀⠀⠀",
      "⠀⠀⠀⠸⠿⠷⠒⣦⣤⣴⣶⢿⣿⡀⠀⠀⠀⣽⡿⢷⣦⠤⢤⡖⠶⠿⠧⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⢿⣦⣴⡾⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
      "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
    }

    -- ── Buttons ──
    dashboard.section.buttons.val = {
      dashboard.button("f", "    Find file", ":Telescope find_files<CR>"),
      dashboard.button("g", "    Live grep", ":Telescope live_grep<CR>"),
      dashboard.button("r", "    Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("e", "    File tree", ":Neotree toggle<CR>"),
      dashboard.button("t", "    Terminal", ":ToggleTerm direction=horizontal<CR>"),
      dashboard.button("?", "    Keybinds", ":lua require('config.cheatsheet')()<CR>"),
      dashboard.button("q", "    Quit", ":qa<CR>"),
    }

    -- ── Footer ──
    local v = vim.version()
    dashboard.section.footer.val = "  v" .. v.major .. "." .. v.minor .. "." .. v.patch

    -- ── Dynamic vertical centering ──
    -- Calculates top padding so the whole section is centered in the window.
    -- Works on both laptop and big-ass screens.
    -- Each button renders 2 rows (button + the group's 1-line spacing), so
    -- the buttons section is BUTTON_COUNT * 2 rows tall.
    local HEADER_LINES = 13
    local BUTTON_COUNT = 7
    local BUTTON_SPACING = 1     -- dashboard theme group opts.spacing
    local BETWEEN_PADDING = 1    -- padding element between header and buttons
    local FOOTER_LINES = 1
    local CONTENT_HEIGHT = HEADER_LINES + BETWEEN_PADDING + BUTTON_COUNT * (1 + BUTTON_SPACING) + FOOTER_LINES

    local function top_padding()
      local win_height = vim.fn.winheight(0)
      local pad = math.floor((win_height - CONTENT_HEIGHT) / 2)
      return math.max(1, pad)
    end

    dashboard.config.opts.margin = 0
    dashboard.config.layout = {
      { type = "padding", val = top_padding },
      dashboard.section.header,
      { type = "padding", val = 1 },
      dashboard.section.buttons,
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)
  end,
}
