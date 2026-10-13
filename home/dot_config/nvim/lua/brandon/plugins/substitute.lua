return {
	"gbprod/substitute.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local substitute = require("substitute")

		substitute.setup()

		local keymap = vim.keymap

		keymap.set("n", "s", substitute.operator, { desc = "Substitute with motion" }, { noremap = true })
		keymap.set("n", "ss", substitute.line, { desc = "Substitute line" }, { noremap = true })
		keymap.set("n", "S", substitute.eol, { desc = "Substitute to end of line" }, { noremap = true })
		keymap.set("x", "s", substitute.visual, { desc = "Substitute in visual mode" }, { noremap = true })
	end,
}
