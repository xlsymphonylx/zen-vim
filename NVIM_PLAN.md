# Nvim Dotfiles — Improvement Plan

> Created: 2026-07-25
> Baseline: `~/.config/nvim/` is a lazy.nvim-based setup, git-tracked as self-managed dotfiles.

---

## Current State

### ✅ Working
| Feature | Plugin / Config | Notes |
|---|---|---|
| File browser | neo-tree.nvim | `<leader>e` toggles |
| Auto-formatter | conform.nvim | Format on save, per-ft config |
| Which-key | which-key.nvim | **Enabled** — shows groups on `<leader>` hold |
| Startup dashboard | alpha-nvim | ASCII logo + quick buttons, auto-opens |
| Custom keybinds | `lua/config/keymaps.lua` | Window nav (Alt+WASD), buffers, line movement |
| File finder | telescope.nvim | `<leader>ff` |
| Live grep | telescope.nvim | `<leader>fg` |
| Terminal toggle | toggleterm.nvim | `<leader>th` / `<leader>tv` |
| LSP | nvim-lspconfig | Servers from Nix, keybinds for gd/K/gr |
| Completion | blink.cmp | LSP + path + snippets + buffer |
| Syntax highlighting | nvim-treesitter | Barebones setup |
| Statusline | lualine.nvim | tokyonight theme |
| Colorscheme | kanagawa.nvim | Wave theme |
| Search & Replace | nvim-spectre | `<leader>sr` / `<leader>sw` |
| Git signs | gitsigns.nvim | Hunk nav, stage, blame, diff |
| Linting | nvim-lint | Only nix/statix |
| Undo persistence | built-in | `undofile = true` |

### ❌ Still Missing / Could Improve
- **Telescope grep_string** — maybe add `<leader>fw` for word-under-cursor search
- **Spectre discoverability** — keybinds shown once via notify, not ideal

---

## What's Been Done

### 1. ✅ Startup Dashboard
- Plugin: `alpha-nvim`
- Shows: ASCII "NVIM" logo, quick buttons (find/grep/recent/tree/terminal/quit), version
- Auto-opens when no file arg; neo-tree no longer auto-opens (still `<leader>e`)

### 2. ✅ Which-Key
- Removed `enable = false` — now functional
- Added `<leader>b` → "Buffer", `<leader>t` → "Terminal"
- Removed dead `<leader>g` → "Git" (nothing uses it)

### 3. ✅ Terminal Toggle
- Plugin: `toggleterm.nvim`
- `<leader>th` → horizontal terminal
- `<leader>tv` → vertical terminal
- `Alt+a/d` navigates between terminal, sidebar, and editor

---

## Verification
- `nvim` → shows dashboard
- `<leader>e` → neo-tree toggle
- `<leader>ff` → fuzzy find
- `<leader>fg` → live grep
- `<leader>th` / `<leader>tv` → terminal toggle
- `<leader>` hold → which-key popup
- `nvim somefile.lua` → opens file directly (no dashboard)
