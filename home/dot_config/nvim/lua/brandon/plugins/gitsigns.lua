return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 500,
		},
		on_attach = function(bufnr)
			local gs = require("gitsigns")

			vim.keymap.set("n", "]c", function()
				if vim.wo.diff then
					return "]c"
				end
				vim.schedule(gs.next_hunk)
				return "<Ignore>"
			end, { expr = true, buffer = bufnr })

			vim.keymap.set("n", "[c", function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(gs.prev_hunk)
				return "<Ignore>"
			end, { expr = true, buffer = bufnr })

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end
			-- Actions
			map("n", "<leader>bf", "<cmd>Gitsigns blame<cr>", { desc = "Open git blame for file" })
		end,
	},
	config = true,
}
