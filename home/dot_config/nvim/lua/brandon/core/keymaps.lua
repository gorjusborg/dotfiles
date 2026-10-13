local nvUtils = require("brandon.utils.nvim")
local dateUtils = require("brandon.utils.date")
local keymap = vim.keymap

vim.g.mapleader = " "
vim.g.maplocalleader = ","

keymap.set("n", "<leader>ht", function()
	print("toggle hlsearch")
	vim.opt_local.hlsearch = not vim.o.hlsearch
end, { desc = "Toggle search highlight visibility" })

-- split management

keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Split equal" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Split equal" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		keymap.set("n", "<localleader>d", function()
			return "a" .. dateUtils.currentDate() .. nvUtils.escapeTermcodes("<esc>")
		end, { expr = true })
		keymap.set("n", "<localleader>t", "o- [ ] ")
		keymap.set("n", "<localleader>T", "O- [ ] ")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	callback = function()
		keymap.set("n", "<localleader>tcc", "o<CR>Co-authored-by: Claude <noreply@anthropic.com><Esc>")
	end,
})
