-- neotree

function ToggleNeotree()
	local view = require("neo-tree.sources.manager").get_state("filesystem").winid

	if view == nil then
		vim.cmd("Neotree toggle")
	else
		if vim.fn.bufname():match("neo%-tree filesystem") then
			vim.cmd("Neotree toggle")
		else
			vim.cmd("Neotree focus")
		end
	end
end

vim.keymap.set("n", "<A-1>", ToggleNeotree, { noremap = true, silent = true })

-- windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<F2>", vim.diagnostic.goto_next, { desc = "Go to next error" })
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { desc = "[W]indow Split [V]ertical" })
vim.keymap.set("n", "<leader>wh", ":split<CR>", { desc = "[W]indow Split [V]ertical" })
vim.keymap.set({ "n", "v", "t", "s", "c", "o", "i" }, "<F1>", "<Esc>")
-- terminal
local api = vim.api

api.nvim_command("autocmd TermOpen * startinsert") -- starts in insert mode
api.nvim_command("autocmd TermOpen * setlocal nonumber") -- no numbers
api.nvim_command("autocmd TermEnter * setlocal signcolumn=no") -- no sign column

vim.keymap.set("t", "<esc>", "<C-\\><C-n>")

vim.keymap.set({ "n", "i" }, "<F12>", ":bot term<CR>", { noremap = true, silent = true, desc = "Open terminal" })

-- telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "leader>cd", vim.lsp.buf.definition, { desc = "[C]ode goto [D]efinition" })
vim.keymap.set({ "n", "v" }, "leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]efinition" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>e", builtin.oldfiles, { desc = "Telescope Lists previously open files" })
vim.keymap.set("n", "leader>cr", builtin.lsp_references, { desc = "[C]ode goto [R]eferences" })
vim.keymap.set("n", "leader>ci", builtin.lsp_references, { desc = "[C]ode goto [I]mplementation" })
vim.keymap.set("n", "<leader>tc", builtin.commands, { desc = "[T]elescope find in [C]ommands" })
vim.keymap.set("n", "<leader>rt", function()
	builtin.commands({ default_text = vim.fn.expand("JavaTest") })
end, { desc = "[T]elescope [R]un [T]ests ]" })
-- which-key
vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, {
	desc = "Buffer Local Keymaps (which-key)",
})

-- conform
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

-- lspconfig
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Goto implementation" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ction" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { noremap = true, silent = true, desc = "Rename" })
vim.keymap.set("n", "<leader>o", vim.lsp.buf.format, { desc = "Format code" })

-- dap
--
vim.keymap.set("n", "<F5>", function()
	require("dap").continue()
end)
vim.keymap.set("n", "<F10>", function()
	require("dap").step_over()
end)
vim.keymap.set("n", "<F11>", function()
	require("dap").step_into()
end)
vim.keymap.set("n", "<F12>", function()
	require("dap").step_out()
end)
vim.keymap.set("n", "<Leader>b", function()
	require("dap").toggle_breakpoint()
end)
vim.keymap.set("n", "<Leader>B", function()
	require("dap").set_breakpoint()
end)
vim.keymap.set("n", "<Leader>lp", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end)
vim.keymap.set("n", "<Leader>dr", function()
	require("dap").repl.open()
end)
vim.keymap.set("n", "<Leader>dl", function()
	require("dap").run_last()
end)
vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
	require("dap.ui.widgets").hover()
end)
vim.keymap.set({ "n", "v" }, "<Leader>dp", function()
	require("dap.ui.widgets").preview()
end)
vim.keymap.set("n", "<Leader>df", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.frames)
end)
vim.keymap.set("n", "<Leader>ds", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end)
