-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

local save_neotree_width = function()
	if #vim.api.nvim_tabpage_list_wins(0) > 1 and vim.api.nvim_win_get_config(0).relative == "" then
		local current_width = vim.api.nvim_win_get_width(0)
		local opts = vim.tbl_deep_extend("force", require("neo-tree").config, {
			filesystem = {
				window = {
					width = current_width,
				},
			},
		})
		require("neo-tree").setup(opts)
	end
end

return {
	"nvim-neo-tree/neo-tree.nvim",
	version = "*",
	branch = "v3.x",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		{
			"s1n7ax/nvim-window-picker",
			version = "2.*",
			config = function()
				require("window-picker").setup({
					filter_rules = {
						include_current_win = false,
						autoselect_one = true,
						-- filter using buffer options
						bo = {
							-- if the file type is one of following, the window will be ignored
							filetype = { "neo-tree", "neo-tree-popup", "notify" },
							-- if the buffer type is one of following, the window will be ignored
							buftype = { "terminal", "quickfix" },
						},
					},
				})
			end,
		},
	},
	cmd = "Neotree",
	keys = {
		{ "\\", ":Neotree left reveal<CR>", desc = "NeoTree reveal", silent = true },
		-- { '<M-\\>', ':Neotree float reveal<CR>', desc = 'NeoTree reveal', silent = true },
		{
			"<leader>E",
			function()
				require("neo-tree.command").execute({ toggle = true, dir = vim.fn.getcwd() })
			end,
			desc = "[E]xplorer NeoTree (Root Dir)",
		},
		{
			"<leader>e",
			function()
				require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
			end,
			desc = "[E]xplorer NeoTree (cwd)",
		},
		-- { '<leader>e', '<leader>fe', desc = 'Explorer NeoTree (Root Dir)', remap = true },
		-- { '<leader>E', '<leader>fE', desc = 'Explorer NeoTree (cwd)', remap = true },
		{
			"<leader>ge",
			function()
				require("neo-tree.command").execute({ source = "git_status", toggle = true })
			end,
			desc = "[G]it [E]xplorer",
		},
		{
			"<leader>be",
			function()
				require("neo-tree.command").execute({ source = "buffers", toggle = true })
			end,
			desc = "[B]uffer [E]xplorer",
		},
		{
			-- '<Esc><Esc>',
			"<leader>\\",
			"<c-w>p",
			-- '<C-w><C-h>',
			-- '<C-w>h',
			-- function()
			--   -- local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
			--   -- vim.cmd 'wincmd l'
			--   vim.cmd 'wincmd p'
			--   --   if ft == 'neo-tree' then
			--   --     save_neotree_width()
			--   --     vim.cmd 'e #'
			--   --   end
			-- end,
			-- mode = { 'n' },
			-- buffer = true,
			ft = { "neo-tree", "neotree" },
			noremap = true,
			silent = true,
			desc = "Switch to Previous Window",
		},
		-- {
		--   '<Esc><Esc>',
		--   function()
		--     local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
		--     if ft == 'neo-tree' then
		--       save_neotree_width()
		--       vim.cmd 'e #'
		--     end
		--   end,
		--   mode = { 'n' },
		--   ft = { 'neo-tree', 'neotree' },
		--   buffer = true,
		--   remap = true,
		--   silent = true,
		--   { desc = 'Switch to Other Buffer' },
		-- },
		-- {
		--   '<Esc><Esc>',
		--   '<cmd>e #<cr>',
		--   mode = { 'n' },
		--   ft = { 'neo-tree', 'neotree' },
		--   buffer = true,
		--   remap = true,
		--   silent = true,
		--
		--   -- function()
		--   --   local ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
		--   --   if ft == 'neo-tree' then
		--   --     vim.cmd 'e #'
		--   --   end
		--   -- end,
		--   { desc = 'Switch to Other Buffer' },
		-- },
	},
	config = function(opts)
		-- If you want icons for diagnostic errors, you'll need to define them somewhere:
		vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })
		opts = {
			enable_git_status = vim.fn.executable("git") == 1,
			auto_clean_after_session_restore = true,
			close_if_last_window = true,
			popup_border_style = "rounded",
			enable_diagnostics = true,
			sources = { "filesystem", "buffers", vim.fn.executable("git") == 1 and "git_status" or nil },
			source_selector = {
				winbar = true,
				content_layout = "center",
				-- sources = sources,
			},
			window = {
				mapping_options = {
					noremap = true,
					nowait = true,
				},
				mappings = {
					-- so that <leader> works even in neo-tree
					["<space>"] = "none",
					-- same as reveal keymap above so that it works like a toggle
					-- ['\\'] = 'close_window',
					["\\"] = {
						command = function(state)
							-- local ok, node = pcall(function()
							--   return state.tree:get_node()
							-- end)
							-- if ok then
							--   print(node.name)
							-- end
							save_neotree_width()
							require("neo-tree.sources.common.commands").close_window(state)
						end,
						desc = "close window with width preserved",
					},
					-- ['<M-\\>'] = {
					--   command = function(state)
					--     save_neotree_width()
					--     require('neo-tree.sources.common.commands').close_window(state)
					--   end,
					--   desc = 'close window with width preserved',
					-- },
					["<S-Tab>"] = "prev_source",
					["<Tab>"] = "next_source",
				},
			},
			open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
			filesystem = {
				filtered_items = {
					visible = true, -- when true, they will just be displayed differently than normal items
					hide_dotfiles = true,
					hide_gitignored = true,
					hide_hidden = true, -- only works on Windows for hidden files/directories
					-- hide_by_name = {
					--   '.DS_Store',
					--   'thumbs.db',
					--   'node_modules',
					--   '__pycache__',
					--   '.virtual_documents',
					--   '.git',
					--   '.python-version',
					--   '.venv',
					-- },
					hide_by_pattern = { -- uses glob style patterns
						--"*.meta",
						--"*/src/*/tsconfig.json",
					},
					always_show = { -- remains visible even if other settings would normally hide it
						--".gitignored",
					},
					never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
						--".DS_Store",
						--"thumbs.db"
					},
					never_show_by_pattern = { -- uses glob style patterns
						--".null-ls_*",
					},
				},
				bind_to_cwd = false,
				follow_current_file = {
					enabled = true,
					leave_dirs_open = true,
				},
				use_libuv_file_watcher = true,
				hijack_netrw_behavior = "open_default",
				window = {
					width = 32,
					mappings = {
						["<c-f>"] = {
							command = function(state)
								local ok, node = pcall(function()
									return state.tree:get_node()
								end)
								if ok then
									require("telescope.builtin").live_grep({ cwd = node.path })
								end
							end,
							desc = "search in directory under cursor",
						},
						["D"] = "show_diff",
					},
				},
				commands = {
					show_diff = function(state)
						-- some variables. use any if you want
						local node = state.tree:get_node()
						-- local abs_path = node.path
						-- local rel_path = vim.fn.fnamemodify(abs_path, ":~:.")
						-- local file_name = node.name
						local is_file = node.type == "file"
						if not is_file then
							vim.notify("Diff only for files", vim.log.levels.ERROR)
							return
						end
						-- open file
						local cc = require("neo-tree.sources.common.commands")
						cc.open(state, function()
							-- do nothing for dirs
						end)

						-- -- I recommend using one of below to show the diffs
						--
						-- -- Raw vim
						-- -- git show ...: change arg as you want
						-- -- @: current file vs git head
						-- -- @^: current file vs previous commit
						-- -- @^^^^: current file vs 4 commits before head and so on...
						-- vim.cmd [[
						--   !git show @^:% > /tmp/%
						--   vert diffs /tmp/%
						-- ]]
						--
						-- -- Fugitive
						-- vim.cmd [[Gdiffsplit]] -- or
						-- vim.cmd [[Ghdiffsplit]] -- or
						-- vim.cmd [[Gvdiffsplit]]

						-- diffview.nvim
						vim.cmd([[DiffviewOpen -- %]])
					end,
				},
			},
			buffers = {
				group_empty_dirs = true, -- when true, empty folders will be grouped together
				show_unloaded = true,
			},
			git_status = {
				window = {
					-- position = 'float',
					mappings = {
						["A"] = "git_add_all",
						["g"] = { "show_help", nowait = false, config = { title = "Git operations", prefix_key = "g" } },
						["gu"] = "git_unstage_file",
						["ga"] = "git_add_file",
						["gr"] = "git_revert_file",
						["gc"] = "git_commit",
						["gp"] = "git_push",
						["gg"] = "git_commit_and_push",
						["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
						["oc"] = { "order_by_created", nowait = false },
						["od"] = { "order_by_diagnostics", nowait = false },
						["om"] = { "order_by_modified", nowait = false },
						["on"] = { "order_by_name", nowait = false },
						["os"] = { "order_by_size", nowait = false },
						["ot"] = { "order_by_type", nowait = false },
					},
				},
			},
			default_component_configs = {
				container = {
					enable_character_fade = true,
				},
				indent = {
					indent_size = 2,
					padding = 1, -- extra padding on left hand side
					-- indent guides
					with_markers = true,
					indent_marker = "│",
					last_indent_marker = "└",
					highlight = "NeoTreeIndentMarker",
					-- expander config, needed for nesting files
					with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
				git_status = {
					symbols = {
						-- Change type
						added = "✚", -- or "✚", but this is redundant info if you use git_status_colors on the name
						modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
						deleted = "✖", -- this can only be used in the git_status source
						renamed = "󰁕", -- this can only be used in the git_status source
						-- Status type
						untracked = "",
						ignored = "",
						unstaged = "󰄱",
						staged = "",
						conflict = "",
						-- unstaged = '󰄱',
						-- staged = '󰱒',
					},
				},
				icon = {
					folder_closed = "",
					folder_open = "",
					folder_empty = "󰜌",
					-- provider = function(icon, node, state) -- default icon provider utilizes nvim-web-devicons if available
					provider = function(icon, node, _) -- default icon provider utilizes nvim-web-devicons if available
						if node.type == "file" or node.type == "terminal" then
							local success, web_devicons = pcall(require, "nvim-web-devicons")
							local name = node.type == "terminal" and "terminal" or node.name
							if success then
								local devicon, hl = web_devicons.get_icon(name)
								icon.text = devicon or icon.text
								icon.highlight = hl or icon.highlight
							end
						end
					end,
					-- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
					-- then these will never be used.
					default = "*",
					highlight = "NeoTreeFileIcon",
				},
				modified = {
					symbol = "[+]",
					highlight = "NeoTreeModified",
				},
				name = {
					trailing_slash = false,
					use_git_status_colors = true,
					highlight = "NeoTreeFileName",
				},
				symlink_target = {
					enabled = true,
				},
			},
		}
		require("neo-tree").setup(opts)
		-- netrw
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
	end,
}
