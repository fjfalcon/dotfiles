return {
	-- https://github.com/akinsho/toggleterm.nvim
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			--[[ things you want to change go here]]
			-- open_mapping = [[<c-\>]],
			start_in_insert = true,
			insert_mappings = true, -- whether or not the open mapping applies in insert mode
			terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
			persist_size = true,
			persist_mode = false,
			winbar = {
				enabled = false,
				name_formatter = function(term) --  term: Terminal
					return term.name
				end,
			}, -- if set to true (default) the previous terminal mode will be remembered
		},
		-- config = function (opts)
		--   require('toggleterm').setup(opts)
		-- end
	},
	-- https://github.com/ryanmsnyder/toggleterm-manager.nvim
	{
		"ryanmsnyder/toggleterm-manager.nvim",
		dependencies = {
			"akinsho/toggleterm.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim", -- only needed because it's a dependency of telescope
		},
		config = true,
	},
	-- https://github.com/willothy/flatten.nvim?tab=readme-ov-file#advanced-configuration-examples
	{
		"willothy/flatten.nvim",
		-- Ensure that it runs first to minimize delay when opening file from terminal
		lazy = false,
		priority = 1001,
		opts = function()
			---@type Terminal?
			local saved_terminal

			return {
				window = {
					open = "alternate",
				},
				callbacks = {
					should_block = function(argv)
						-- Note that argv contains all the parts of the CLI command, including
						-- Neovim's path, commands, options and files.
						-- See: :help v:argv

						-- In this case, we would block if we find the `-b` flag
						-- This allows you to use `nvim -b file1` instead of
						-- `nvim --cmd 'let g:flatten_wait=1' file1`
						return vim.tbl_contains(argv, "-b")

						-- Alternatively, we can block if we find the diff-mode option
						-- return vim.tbl_contains(argv, "-d")
					end,
					pre_open = function()
						local term = require("toggleterm.terminal")
						local termid = term.get_focused_id()
						saved_terminal = term.get(termid)
					end,
					post_open = function(bufnr, winnr, ft, is_blocking)
						if is_blocking and saved_terminal then
							-- Hide the terminal while it's blocking
							saved_terminal:close()
						else
							-- If it's a normal file, just switch to its window
							vim.api.nvim_set_current_win(winnr)
						end

						-- If the file is a git commit, create one-shot autocmd to delete its buffer on write
						-- If you just want the toggleable terminal integration, ignore this bit
						if ft == "gitcommit" or ft == "gitrebase" then
							vim.api.nvim_create_autocmd("BufWritePost", {
								buffer = bufnr,
								once = true,
								callback = vim.schedule_wrap(function()
									vim.api.nvim_buf_delete(bufnr, {})
								end),
							})
						end
					end,
					block_end = function()
						-- After blocking ends (for a git commit, etc), reopen the terminal
						vim.schedule(function()
							if saved_terminal then
								saved_terminal:open()
								saved_terminal = nil
							end
						end)
					end,
				},
			}
		end,
	},
	-- {
	--   'willothy/flatten.nvim',
	--   config = true,
	--   -- or pass configuration with
	--   -- opts = {  }
	--   -- Ensure that it runs first to minimize delay when opening file from terminal
	--   lazy = false,
	--   priority = 1001,
	-- },
}
