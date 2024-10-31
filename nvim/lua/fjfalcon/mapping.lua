vim.keymap.set(
	"n",
	"<A-1>",
	--        function()
	--                if (vim.fn.bufname():match 'NvimTree_') then
	--                        "<Cmd>Neotree toogle position=left<CR>"
	--                end
	--        end
	--        )
	"<Cmd>Neotree toggle position=left<CR>"
)

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<F2>", vim.diagnostic.goto_next, { desc = "Go to next error" })
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { desc = "[W]indow Split [V]ertical" })
vim.keymap.set("n", "<leader>wh", ":split<CR>", { desc = "[W]indow Split [V]ertical" })

local api = vim.api

api.nvim_command("autocmd TermOpen * startinsert") -- starts in insert mode
api.nvim_command("autocmd TermOpen * setlocal nonumber") -- no numbers
api.nvim_command("autocmd TermEnter * setlocal signcolumn=no") -- no sign column

vim.keymap.set("t", "<esc>", "<C-\\><C-n>")

vim.keymap.set({ "n", "i" }, "<F12>", ":bot term<CR>", { noremap = true, silent = true, desc = "Open terminal" })
