return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-ui-select.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "leader>cd", vim.lsp.buf.definition, { desc = "[C]ode goto [D]efinition" })
			vim.keymap.set({ "n", "v" }, "leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]efinition" })
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>e", builtin.oldfiles, { desc = "Telescope Lists previously open files" })
			vim.keymap.set(
				"n",
				"leader>cr",
				require("telescope.builtin").lsp_references,
				{ desc = "[C]ode goto [R]eferences" }
			)
			vim.keymap.set(
				"n",
				"leader>ci",
				require("telescope.builtin").lsp_references,
				{ desc = "[C]ode goto [I]mplementation" }
			)
			require("telescope").setup({
				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown() },
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
