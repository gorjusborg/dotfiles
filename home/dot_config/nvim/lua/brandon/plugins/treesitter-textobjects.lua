-- the following is a lazy.nvim config for nvim-treesitter-textobjects
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	init = function()
		-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
		vim.g.no_plugin_maps = true -- Disable entire built-in ftplugin mappings to avoid conflicts.
	end,
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
			},
			move = {
				set_jumps = true, -- record jump in jump list
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		local move = require("nvim-treesitter-textobjects.move")

		local selects = {
			["ab"] = { "@block.outer", "around block" },
			["ib"] = { "@block.inner", "in block" },

			["ac"] = { "@comment.outer", "around comment" },
			["ic"] = { "@comment.inner", "in comment" },

			["ak"] = { "@class.outer", "around class" },
			["ik"] = { "@class.inner", "in class" },

			["af"] = { "@function.outer", "around function" },
			["if"] = { "@function.inner", "in function" },
		}
		for lhs, obj in pairs(selects) do
			vim.keymap.set({ "x", "o" }, lhs, function()
				select.select_textobject(obj[1], "textobjects")
			end, { desc = obj[2] })
		end

		local moves = {
			{ "b", "@block.outer", "block" },
			{ "c", "@comment.outer", "comment" },
			{ "k", "@class.outer", "class" },
			{ "f", "@function.outer", "function" },
		}
		for _, m in ipairs(moves) do
			vim.keymap.set({ "n", "x", "o" }, "]" .. m[1], function()
				move.goto_next_start(m[2], "textobjects")
			end, { desc = "go next " .. m[3] })
			vim.keymap.set({ "n", "x", "o" }, "[" .. m[1], function()
				move.goto_previous_start(m[2], "textobjects")
			end, { desc = "go previous " .. m[3] })
		end
	end,
}
