vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.relativenumber = true
opt.number = true
opt.signcolumn = "yes" --show sign column so that text doesn't shift

--tabs & indentation

opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.wrap = true

--search settings

opt.ignorecase = true
opt.smartcase = true
opt.cursorline = true

-- terminal colors
opt.termguicolors = true
opt.background = "dark" -- colorschemes with dark/light option will use dark

--backspace
opt.backspace = "indent,eol,start"

--clipboard
opt.clipboard:append("unnamedplus") --use system clipboard as default register
opt.mouse = "" -- disable neovim rat support

--split windows
opt.splitright = true
opt.splitbelow = true

--diffs
opt.diffopt = "internal,filler,closeoff,linematch:60"

-- automatically load buffer if changed outside neovim
opt.autoread = true
