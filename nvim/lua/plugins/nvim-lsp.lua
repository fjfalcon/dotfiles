return {
	{
		"williamboman/mason.nvim",
		opts = {
			registries = {
				"github:nvim-java/mason-registry",
				"github:mason-org/mason-registry",
			},
		},
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls", -- Lua
					"jsonls", -- JSON
				},
				automatic_installation = true,
			})
		end,
	},
	{
		"nvim-java/nvim-java",
	},
	{
		"nvim-java/lua-async",
	},
	{
		"nvim-java/nvim-java-core",
	},
	{
		"nvim-java/nvim-java-refactor",
	},
	{
		"nvim-java/nvim-java-test",
	},
	{
		"nvim-java/nvim-java-dap",
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
							path = vim.split(package.path, ";"),
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = { vim.env.VIMRUNTIME },
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})
			require("java").setup({})
			lspconfig.jdtls.setup({})
		end,
		setup = {},
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
	},
	{
		"mfussenegger/nvim-jdtls",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
		lazy = true,
		ft = { "java" },
	},
}
