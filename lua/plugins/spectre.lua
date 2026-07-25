return {
  "windwp/nvim-spectre",
  cmd = { "Spectre", "SpectreOpen" },
  keys = {
    { "<leader>sr", function() require("spectre").open() end, desc = "Search & replace (spectre)" },
    { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search word under cursor" },
  },
  opts = {
    result_padding = "  ",
    mapping = {
      ["toggle_line"] = {
        map = "dd",
        cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
      },
      ["send_to_qf"] = {
        map = "<C-q>",
        cmd = ":lua require('spectre').send_to_qf()<CR>",
      },
      ["replace_cmd"] = {
        map = "<C-c>",
        cmd = "<cmd>lua require('spectre').replace_current_line()<CR>",
      },
      ["replace_all"] = {
        map = "<C-a>",
        cmd = "<cmd>lua require('spectre').replace_all()<CR>",
      },
    },
  },
  config = function(_, opts)
    require("spectre").setup(opts)

    -- Show keybind help when entering spectre buffer
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "spectre",
      callback = function()
        -- Debounce: only show once per session
        if vim.g.spectre_help_shown then return end
        vim.g.spectre_help_shown = true
        vim.schedule(function()
          vim.notify([[
Spectre keybinds:
  Ctrl+a  Replace all    Ctrl+c  Replace current line
  dd      Toggle line    Ctrl+q  Send to quickfix
  Press ? in Spectre to show this again]], vim.log.levels.INFO, { title = "Spectre" })
        end)

        -- ? key to reshow help
        vim.keymap.set("n", "?", function()
          vim.notify([[
Spectre keybinds:
  Ctrl+a  Replace all    Ctrl+c  Replace current line
  dd      Toggle line    Ctrl+q  Send to quickfix]], vim.log.levels.INFO, { title = "Spectre" })
        end, { buffer = true, silent = true, desc = "Show spectre help" })
      end,
    })
  end,
}
