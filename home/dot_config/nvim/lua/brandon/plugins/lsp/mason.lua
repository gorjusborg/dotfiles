local machine = require("brandon.machine")

-- Tools installed on every machine (mason package or lspconfig names).
local tools = {
	"clojure-lsp",
	"isort",
	"prettier",
	"pylint",
	"stylua",
	"ts_ls",
	{ "eslint_d", version = "13.1.2" },
}

local work_tools = {
	"black",
}

local personal_tools = {
	"basedpyright",
	"gopls",
	"zls",
}

vim.list_extend(tools, machine.work and work_tools or personal_tools)

return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_tool_installer = require("mason-tool-installer")

		mason.setup({
			ui = {
				icons = {
					package_installed = "󰄬",
					package_pending = "󰦖",
					package_uninstalled = "",
				},
			},
		})

		mason_lspconfig.setup()

		mason_tool_installer.setup({
			ensure_installed = tools,
		})
	end,
}
