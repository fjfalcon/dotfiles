return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependecies = {
			"nvia-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			require("neo-tree").setup({
				auto_expand_width = true,
			})
		end,
	},
}
