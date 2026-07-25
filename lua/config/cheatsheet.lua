local bindings = {
  { "File / Tree", {
    { "<leader>e",   "Toggle file tree" },
    { "<leader>ff",  "Find files" },
    { "<leader>fr",  "Recent files" },
    { "<leader>w",   "Save file" },
  }},
  { "Search", {
    { "<leader>fg",  "Live grep (keyword)" },
    { "<leader>fb",  "Buffers list" },
    { "<leader>fc",  "Colorschemes" },
  }},
  { "Buffer", {
    { "<leader>bd",  "Delete buffer" },
    { "<leader><Right>", "Next buffer" },
    { "<leader><Left>",  "Previous buffer" },
  }},
  { "Terminal", {
    { "<leader>th",  "Toggle horizontal terminal" },
    { "<leader>tv",  "Toggle vertical terminal" },
    { "<leader>gg",  "Toggle lazygit (float)" },
  }},
  { "Git", {
    { "<leader>hs",  "Stage hunk" },
    { "<leader>hr",  "Reset hunk" },
    { "<leader>hb",  "Blame line" },
    { "<leader>hd",  "Diff" },
  }},
  { "Window", {
    { "Alt + w/a/s/d", "Navigate windows" },
    { "Ctrl + arrows",  "Resize window" },
  }},
  { "LSP", {
    { "gd",  "Go to definition" },
    { "gr",  "Go to references" },
    { "K",   "Hover info" },
    { "<leader>rn", "Rename" },
    { "<leader>ca", "Code action" },
    { "<leader>d",  "Diagnostic float (current line)" },
    { "<leader>ld", "List all diagnostics" },
    { "]d",  "Next diagnostic" },
    { "[d",  "Previous diagnostic" },
  }},
  { "Search & Replace", {
    { "<leader>sr", "Open Spectre" },
    { "<leader>sw", "Search word under cursor" },
  }},
  { "Snippets", {
    { "<leader>ss", "List available snippets" },
    { "rfc",       "React functional component" },
    { "clg",       "console.log()" },
    { "cfn",       "const name = () => {}" },
    { "fn",        "function name() {}" },
    { "afn",       "async function name() {}" },
    { "cafn",      "const name = async () => {}" },
  }},
  { "CSS Classes", {
    { "<leader>sc", "Refresh SCSS class cache" },
    { "(auto)",    "SCSS classes in JSX/HTML completions" },
    { "(auto)",    "JSX classes in SCSS completions" },
  }},
}

return function()
  local width = 72
  local height = #bindings * 3 + 4
  height = math.min(height, 30)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Keybinds ",
    title_pos = "center",
  })

  vim.wo[win].cursorline = false
  vim.bo[buf].buftype = "nofile"
  vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>q<CR>", { silent = true, nowait = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<ESC>", "<cmd>q<CR>", { silent = true, nowait = true })

  local lines = {}
  for _, section in ipairs(bindings) do
    table.insert(lines, "  " .. section[1])
    table.insert(lines, "  " .. string.rep("─", 68))
    for _, binding in ipairs(section[2]) do
      local key = binding[1]
      local desc = binding[2]
      local padding = string.rep(" ", math.max(1, 28 - #key))
      table.insert(lines, "    " .. key .. padding .. desc)
    end
    table.insert(lines, "")
  end
  table.insert(lines, "  Press q or ESC to close")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(win, { 1, 0 })
end
