return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Goto implementation" })
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
			vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { noremap = true, silent = true, desc = "Rename" })
			vim.keymap.set("n", "<leader>o", vim.lsp.buf.format, { desc = "Format code" })
			lspconfig.lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
							version = "LuaJIT",
							path = vim.split(package.path, ";"),
						},
						diagnostics = {
							-- Get the language server to recognize the `vim` global
							globals = { "vim" },
						},
						workspace = {
							-- Make the server aware of Neovim runtime files and plugins
							library = { vim.env.VIMRUNTIME },
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})
		end,
		setup = {

			--			require("lspconfig").jdtls.setup({}),
			--			require("java").setup({}),
		},
	},
}
