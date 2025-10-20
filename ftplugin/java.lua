local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = "/home/fjfalcon/dev/workspaces/" .. project_name

local config = {
	cmd = {
		"java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declispe.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocl=true",
		"-Dlog.level=ALL",
		"-Xmx4g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang==ALL-UNNAMED",
		"-jar",
		"/usr/share/java/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar",
		"-configuration",
		"/usr/share/java/jdtls/config_linux",
		"-data",
		workspace_dir,
	},
	root_dir = vim.fs.root(0, { ".git" }),
	settings = {
		java = {},
	},

	init_options = {
		bundles = {},
	},
	capabilities = {
		workspace = {
			configuration = true,
		},
		textDocument = {
			completion = {
				completionItem = {
					snippentSupport = true,
				},
			},
		},
	},
}

config.capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("jdtls").start_or_attach(config)
