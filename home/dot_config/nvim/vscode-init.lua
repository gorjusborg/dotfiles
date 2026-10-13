local api = vim.api
local cmd = vim.cmd
local g = vim.g
local b = vim.b
local o = vim.o
local keymap = vim.keymap

vim.g.mapleader = "\\"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
{'kylechui/nvim-surround'},

{'nvim-lua/plenary.nvim'},
})

require("nvim-surround").setup()

---
--  escapes termcodes
--  usage: t_'somestring'
local function t_(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

g.maplocalleader = ","

keymap.set('n', '<leader><space>', function() o.hlsearch=false end, {silent = true})

-- ex abbreviations
-- keymap.set('ca', ...) doesn't seem supported in neovim 9.1
cmd([[
  cnoreabbrev fmtxml !xmllint --format -
  cnoreabbrev fmtjson !jq . --
]])

local function currentDate()
  local dfields = os.date("*t")
  local date = string.format("%04d-%02d-%02d", dfields.year, dfields.month, dfields.day)
  return date
end

local function brandonMarkdownKeymaps()
  keymap.set('n', '<localleader>d', "a"..currentDate()..t_"<esc>")
  keymap.set('n', '<localleader>t', "o- [ ] ")
  keymap.set('n', '<localleader>T', "O- [ ] ")
end

api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = brandonMarkdownKeymaps
})


--- lsp keybinds

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
