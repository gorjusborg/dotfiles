-- ex abbreviations
-- keymap.set('ca', ...) doesn't seem supported in neovim 9.1
vim.cmd([[
  cnoreabbrev fmtxml !xmllint --format -
  cnoreabbrev fmtjson !jq . --
]])

