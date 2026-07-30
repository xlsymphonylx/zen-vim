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
    local HEADER_LINES = 13
    local BUTTON_COUNT = 7
    local BETWEEN_PADDING = 2    -- 1 before buttons + 1 after header
    local CONTENT_HEIGHT = HEADER_LINES + BUTTON_COUNT + BETWEEN_PADDING + 1 -- +1 for footer

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
