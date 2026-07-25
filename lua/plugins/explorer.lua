return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file tree" },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
      },
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    window = {
      position = "left",
      width = 30,
      mappings = {
        ["<CR>"] = "open",
        ["<C-v>"] = "open_vsplit",
        ["<C-s>"] = "open_split",
        ["<C-t>"] = "open_tabnew",
        ["."] = "toggle_hidden",
      },
    },
    default_component_configs = {
      indent = { padding = 1 },
    },
  },
}
