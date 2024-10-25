return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>n", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>e", builtin.oldfiles, { desc = "Telescope Lists previously open files" })
		end,
	},
}
