return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = { "Telescope" },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
    { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
    { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
    { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
    { "<leader>fc", "<cmd>Telescope colorscheme<CR>", desc = "Colorschemes" },
  },
  config = function()
    -- Pre-load stub for nvim-treesitter.configs (require fails on this nvim version)
    -- Telescope checks this module for preview highlighting, so it must exist
    package.loaded["nvim-treesitter.configs"] = {
      is_enabled = function() return false end,
    }
    -- Also add ft_to_lang to parsers if missing
    local ok, parsers = pcall(require, "nvim-treesitter.parsers")
    if ok and parsers and not parsers.ft_to_lang then
      parsers.ft_to_lang = function(ft)
        local lang = vim.treesitter.language.get_lang(ft)
        return lang or ft
      end
    end

    require("telescope").setup({
      defaults = {
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      },
    })
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>f.", builtin.resume, { desc = "Resume telescope" })
  end,
}
