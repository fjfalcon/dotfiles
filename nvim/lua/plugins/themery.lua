return {
	"zaldih/themery.nvim",
	lazy = false,
	config = function()
		require("themery").setup({
			themes = { "solarized", "catppuccin-latte" },
		})
	end,
}
