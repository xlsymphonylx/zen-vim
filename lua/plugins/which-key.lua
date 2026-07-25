return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	enable = false,
	opts = {
		preset = "modern",
		defaults = {
			mode = { "n", "v" },
			["<leader>f"] = { name = "Find" },
			["<leader>g"] = { name = "Git" },
			["<leader>h"] = { name = "Hunk" },
			["<leader>s"] = { name = "Search" },
		},
	},
}
