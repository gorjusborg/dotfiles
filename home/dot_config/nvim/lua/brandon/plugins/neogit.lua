return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"sindrets/diffview.nvim", --optional: diff integration

		"nvim-telescope/telescope.nvim",
	},
	opts = {},
	config = function(_, opts)
		local neogit = require("neogit")
		neogit.setup(opts)
	end,
	cmd = "Neogit",
	keys = {
		{ "<leader>g", "<cmd>Neogit<CR>", desc = "Open neogit" },
	},
}
