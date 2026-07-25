# Nvim Dotfiles — Improvement Plan

> Created: 2026-07-25
> Baseline: current `.config/nvim/` is a lazy.nvim-based setup, git-tracked as self-managed dotfiles (no Home Manager).

---

## Current State

### ✅ Working
| Feature | Plugin | Notes |
|---|---|---|
| File browser | neo-tree.nvim | `<leader>e`, opens on startup |
| Auto-formatter | conform.nvim | Format on save, per-ft config |
| Which-key | which-key.nvim | **Installed but `enable = false`** — disabled! |
| Custom keybinds | `lua/config/keymaps.lua` | Window nav (Alt+WASD), buffers, line movement, etc. |
| File finder | telescope.nvim | `<leader>ff` find files |
| Live grep | telescope.nvim | `<leader>fg` — already here! |
| LSP | nvim-lspconfig | Servers from Nix, keybinds for gd/K/gr etc. |
| Completion | blink.cmp | LSP + path + snippets + buffer sources |
| Syntax highlighting | nvim-treesitter | Barebones setup (no extra config) |
| Statusline | lualine.nvim | tokyonight theme |
| Colorscheme | kanagawa.nvim | Wave theme |
| Search & Replace | nvim-spectre | `<leader>sr` / `<leader>sw` |
| Git signs | gitsigns.nvim | Hunk nav, stage, blame, diff |
| Linting | nvim-lint | Only nix/statix configured |
| Undo persistence | built-in | `undofile = true` |

### ❌ Missing / Disabled
| Feature | Status | Notes |
|---|---|---|
| **Startup dashboard** | **Missing** | Want LazyVim-style startup screen (recent files, quick links) |
| **Which-key** | **Disabled** | `enable = false` in config — needs to be turned on |
| Spectre discoverability | Weak | Keybinds shown once via notify, not ideal |

---

## Desired Changes

### 1. Startup Dashboard
- Plugin: `alpha-nvim` or `dashboard-nvim` (prefer alpha — lightweight, LazyVim-compatible style)
- Show: recent files, bookmark links, nvim version, session info
- Auto-open when nvim starts without a file argument (replaces neo-tree taking that role)

### 2. Enable Which-Key
- Flip `enable = false` → `enable = true` (or remove the line)
- Already has good group labels (`<leader>f` = Find, `<leader>g` = Git, etc.)
- Add missing group labels for `<leader>s` (Spectre) and any future groups

### 3. Review Telescope + Live Grep
- Live grep already works via `<leader>fg`
- Potentially add grep-string support / `Telescope grep_string` for word-under-cursor
- Maybe add a keybind for `<leader>fw` (grep word under cursor)

### 4. Polish & Discoverability
- Ensure `which-key` properly reflects all keybinds
- Consider adding `<leader>ft` for toggle terminal if needed
- Document keybinds in a single place

---

## Implementation Order
1. Add startup dashboard plugin (alpha-nvim)
2. Enable which-key
3. Polish telescope keybinds
4. Verify LSP/completion still work
5. Commit

## Verification
- `nvim` without args → shows dashboard (not neotree)
- `<leader>e` → still toggles neotree
- `<leader>ff` → fuzzy find
- `<leader>fg` → live grep
- `<leader>` wait → which-key popup shows all groups
- Auto-format on save still works
