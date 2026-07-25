return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local map = vim.keymap.set
      local opts = { noremap = true, silent = true, buffer = bufnr }

      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() require("gitsigns").next_hunk() end)
        return "<Ignore>"
      end, { expr = true, buffer = bufnr })

      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() require("gitsigns").prev_hunk() end)
        return "<Ignore>"
      end, { expr = true, buffer = bufnr })

      map("n", "<leader>hs", require("gitsigns").stage_hunk, opts)
      map("n", "<leader>hr", require("gitsigns").reset_hunk, opts)
      map("n", "<leader>hb", require("gitsigns").blame_line, opts)
      map("n", "<leader>hd", require("gitsigns").diffthis, opts)
    end,
  },
}
