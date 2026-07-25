local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key
vim.g.mapleader = " "

-- ===== Window navigation (WASD with Alt) =====
map("n", "<A-w>", "<C-w>k", opts) -- up
map("n", "<A-a>", "<C-w>h", opts) -- left
map("n", "<A-s>", "<C-w>j", opts) -- down
map("n", "<A-d>", "<C-w>l", opts) -- right

-- Resize with arrows
map("n", "<C-Up>", ":resize -2<CR>", opts)
map("n", "<C-Down>", ":resize +2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- ===== Buffers (open files) =====
map("n", "<leader><Right>", ":bnext<CR>", opts)
map("n", "<leader><Left>", ":bprevious<CR>", opts)
map("n", "<leader>bd", ":bdelete<CR>", opts)

-- ===== Line movement =====
map("n", "<A-j>", ":m .+1<CR>==", opts)
map("n", "<A-k>", ":m .-2<CR>==", opts)
map("x", "<A-j>", ":m '>+1<CR>gv=gv", opts)
map("x", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- ===== Editing =====
map("n", "<leader>w", "<cmd>write<CR>", opts)
map("x", "p", '"_dP', opts)

-- ===== Search =====
map("n", "J", "mzJ`z", opts)

-- ===== Tab navigation =====
map("n", "<A-S-a>", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
map("n", "<A-S-d>", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "<A-S-n>", "<cmd>tabnew<CR>", { desc = "New empty tab" })
map("n", "<A-S-q>", "<cmd>tabclose<CR>", { desc = "Close tab" })
