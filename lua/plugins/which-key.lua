return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		defaults = {
			mode = { "n", "v" },
			["<leader>b"] = { name = "Buffer" },
			["<leader>f"] = { name = "Find" },
			["<leader>g"] = { name = "Git" },
			["<leader>h"] = { name = "Hunk" },
			["<leader>l"] = { name = "LSP" },
			["<leader>s"] = { name = "Search" },
			["<leader>t"] = { name = "Terminal" },
		},
	},
}
