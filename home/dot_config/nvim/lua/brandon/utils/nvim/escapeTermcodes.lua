---
--  escapes termcodes
--  usage: escapeTermcodes'somestring'
function escapeTermcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

return escapeTermcodes

