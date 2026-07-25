return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		defaults = {
			mode = { "n", "v" },
			["<leader>b"] = { name = "Buffer" },
			["<leader>f"] = { name = "Find" },
			["<leader>h"] = { name = "Hunk" },
			["<leader>s"] = { name = "Search" },
			["<leader>t"] = { name = "Terminal" },
		},
	},
}
