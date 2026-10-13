return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false, -- main branch does not support lazy-loading
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		require("nvim-treesitter").install({
			"json",
			"javascript",
			"typescript",
			"tsx",
			"yaml",
			"html",
			"css",
			"markdown",
			"markdown_inline",
			"bash",
			"lua",
			"vim",
			"dockerfile",
			"gitignore",
			"query",
			"vimdoc",
			"c",
			"clojure",
		})

		-- enable highlighting and indentation for any filetype with an installed parser
		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("brandon-treesitter", { clear = true }),
			callback = function(args)
				if not pcall(vim.treesitter.start, args.buf) then
					return
				end
				local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
				if lang and vim.treesitter.query.get(lang, "indents") then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		require("nvim-ts-autotag").setup()

		-- incremental selection, built into neovim 0.12 as `an` / `in` in visual mode
		vim.keymap.set("n", "<C-space>", "van", { remap = true, desc = "Start node selection" })
		vim.keymap.set("x", "<C-space>", "an", { remap = true, desc = "Expand node selection" })
		vim.keymap.set("x", "<bs>", "in", { remap = true, desc = "Shrink node selection" })
	end,
}
