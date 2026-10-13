return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
	opts = {},
	config = true,
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Toggle trouble diagnostics" },
		{
			"<leader>xw",
			"<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
			desc = "Toggle trouble document diagnostics",
		},
		{ "<leader>xd", "<cmd>Trouble quickfix toggle<CR>", desc = "Toggle trouble quickfix list" },
		{ "<leader>xl", "<cmd>Trouble loclist toggle<CR>", desc = "Toggle trouble location list" },
		{ "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "Open TODOs in trouble" },
	},
}
