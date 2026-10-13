return {
	"L3MON4D3/LuaSnip",
	version = "v2.3.0",
	build = "make install_jsregexp",
	dependencies = {
		"rafamadriz/friendly-snippets",
	},
	config = function()
		-- for 'friendly-snippets'
		require("luasnip.loaders.from_vscode").lazy_load()

		-- for custom snippets
		require("luasnip.loaders.from_lua").lazy_load()

		local ls = require("luasnip")
		local types = require("luasnip.util.types")

		local options = {
			history = true,

			updateevents = "TextChanged,TextChangedI",

			enable_autosnippets = true,

			ext_opts = {
				[types.choiceNode] = {
					active = {
						virt_text = { { "<-", "Error" } },
					},
				},
			},
		}

		ls.setup(options)

		ls.filetype_extend("typescript", { "javascript" })

		-- from https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#adding-snippets
		local s = ls.snippet
		local sn = ls.snippet_node
		local isn = ls.indent_snippet_node
		local t = ls.text_node
		local i = ls.insert_node
		local f = ls.function_node
		local c = ls.choice_node
		local d = ls.dynamic_node
		local r = ls.restore_node
		local events = require("luasnip.util.events")
		local ai = require("luasnip.nodes.absolute_indexer")
		local extras = require("luasnip.extras")
		local l = extras.lambda
		local rep = extras.rep
		local p = extras.partial
		local m = extras.match
		local n = extras.nonempty
		local dl = extras.dynamic_lambda
		local fmt = require("luasnip.extras.fmt").fmt
		local fmta = require("luasnip.extras.fmt").fmta
		local conds = require("luasnip.extras.expand_conditions")
		local postfix = require("luasnip.extras.postfix").postfix
		local types = require("luasnip.util.types")
		local parse = require("luasnip.util.parser").parse_snippet
		local ms = ls.multi_snippet
		local k = require("luasnip.nodes.key_indexer").new_key

		-- setup luasnip keybinds
		vim.keymap.set({ "i", "s" }, "<c-k>", function()
			if ls.expand_or_jumpable() then
				ls.expand_or_jump()
			end
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<c-j>", function()
			if ls.jumpable(-1) then
				ls.jump(-1)
			end
		end, { silent = true })

		vim.keymap.set({ "i" }, "<c-l>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end)

		vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/brandon/plugins/luasnip.lua")
	end,
}
