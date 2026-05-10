-- lua/options.lua

local opt = vim.opt

-- Configuraciones generales de Neovim
opt.number = true
opt.relativenumber = true
opt.cursorline = true -- Resalta la línea donde está el cursor
opt.cursorcolumn = true
opt.wrap = true -- Hace que el texto de las líneas largas (las que sobrepasan el ancho de la pantalla) siempre esté visible.
opt.breakindent = true -- Conserva la indentación de las líneas que sólo son visibles cuando wrap es true
opt.textwidth = 0 -- valor 0 desactiva la opción (valores 80 o 120)
-- tabs & indentation
opt.tabstop = 4 -- La cantidad de carácteres que ocupa Tab. El valor por defecto es 8.
opt.shiftwidth = 4 -- El espacio que Neovim usará para indentar una línea (en consonancia con tabstop)
opt.expandtab = true -- Determina si Neovim debe transformar el carácter Tab en espacios. Su valor por defecto es false.
opt.autoindent = true
opt.smartindent = true

opt.iskeyword:append("-") -- añade el carácter - a la lista de caracteres que Neovim considera como parte de una palabra.
opt.syntax = "enable"
opt.mouse = "a" -- Se activa todos los modos de mouse

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive
opt.hlsearch = false -- desactiva resaltado de busquedas anteriores

-- Activar la statusline
opt.laststatus = 2

-- Configuración básica de la statusline
opt.statusline = "%f %y %m %r %= %-14.(%l,%c%V%) %P"

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
--opt.clipboard:append("unnamedplus") -- use system clipboard as default register
opt.clipboard = "unnamedplus"

-- Configuración específica para archivos Markdown
vim.cmd([[ augroup obsidian autocmd! autocmd BufEnter *.md set conceallevel=2 augroup END ]])

-- disable codeium by default
vim.g.codeium_enabled = false

-- Recommended sessionoptions config for auto-session plugin
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
