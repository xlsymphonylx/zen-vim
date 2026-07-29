local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Auto-resync on file change outside vim
augroup("AutoRead", { clear = true })
autocmd({ "FocusGained", "BufEnter" }, {
  group = "AutoRead",
  command = "checktime",
})

-- Return to last cursor position
augroup("LastPosition", { clear = true })
autocmd("BufReadPost", {
  group = "LastPosition",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lc = mark[1]
    if lc > 1 and lc <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- When opening a directory (e.g. `nvim /some/folder`), show dashboard + neo-tree sidebar
augroup("DashboardOnDir", { clear = true })
autocmd("VimEnter", {
  group = "DashboardOnDir",
  nested = true,
  callback = function()
    if vim.fn.argc() == 1 then
      local arg = vim.fn.argv(0)
      if vim.fn.isdirectory(arg) == 1 then
        vim.schedule(function()
          pcall(vim.api.nvim_buf_delete, vim.api.nvim_get_current_buf(), { force = true })
          vim.fn.chdir(arg)
          vim.cmd("Alpha")
          vim.cmd("Neotree show")
        end)
      end
    end
  end,
})

-- Trim trailing whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})
