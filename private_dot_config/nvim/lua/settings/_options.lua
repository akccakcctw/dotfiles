local opt = vim.opt
local options = safe_require('libraries._set_options')

if not options then
	return
end

-- general
opt.history = 500
opt.shell = os.getenv('SHELL') or "/bin/sh"
opt.ttyfast = true

-- use the OS clipboard by default
if vim.fn.has('macunix') == 1 then
	opt.clipboard = 'unnamed'  -- mac
else
	opt.clipboard:append('unnamedplus')  -- linux
end

if not vim.fn.has('nvim') then
	opt.compatible = false
	if string.match(vim.o.term, '^screen') or string.match(vim.o.term, '^tmux') and os.getenv('TMUX') then
		if string.match(vim.o.term, '256color') then
			opt.term = 'xterm-256color'
		else
			opt.term = 'xterm'
		end
	end
	if string.match(vim.o.term, '256color') then
		opt.t_ut = ''
	end
	if vim.fn.has('termguicolors') == 1 then
		-- set Vim-specific sequences for RGB colors
		opt.t_8f = "\\[38;2;%lu;%lu;%lum"
		opt.t_8b = "\\[48;2;%lu;%lu;%lum"
		-- enable true colors
		opt.termguicolors = true
	end

	-- setting host programs
	if vim.fn.has('macunix') == 1 then
		vim.g.python3_host_prog = '/usr/bin/python3'
		vim.g.node_host_prog = '/usr/local/lib/node_modules/neovim/bin/cli.js'
	else
		vim.g.python3_host_prog = '/usr/bin/python3'
		vim.g.node_host_prog = '/usr/lib/node_modules/neovim/bin/cli.js'
	end
end

-- support mouse resize split inside tmux
if not vim.fn.has('nvim') then
	if vim.fn.has('mouse_sgr') == 1 then
		opt.ttymouse = 'sgr'
	else
		opt.ttymouse = 'xterm2'
	end
end

-- Enable syntax highlighting and set background to dark
vim.cmd('syntax on')
opt.background = 'dark'

-- GUI-specific settings
if vim.fn.has('gui_running') == 1 then
	vim.cmd('colorscheme codedark')
	-- Set GUI font based on the OS
	if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
		opt.guifont = 'Consolas:h18'  -- for Windows
	elseif vim.fn.has('unix') == 1 then
		opt.guifont = 'monospace 18'  -- for Linux
	elseif vim.fn.has('macunix') == 1 then
		opt.guifont = 'Monaco:h18'    -- for macOS
	end
end

-- Highlighting for folded text
vim.cmd('hi Folded ctermfg=59')

-- colorscheme
opt.bg = 'dark'
vim.cmd('colorscheme codedark')

-- UI settings
opt.number = true
opt.relativenumber = true
opt.showmatch = true
opt.scrolloff = 3 -- when scrolling, keep cursor 3 lines away from screen border
opt.timeout = true
opt.ttimeoutlen = 10
opt.virtualedit = 'block'
opt.lazyredraw = false -- When this option is set, the screen will not be redrawn while executing macros, registers and other commands that have not been typed.  Also, updating the window title is postponed.
opt.whichwrap:append('<>[]')
opt.startofline = false
opt.autoread = true -- auto read when a file is changed from the outside
opt.backspace = 'indent,eol,start'
opt.autoindent = true
opt.wrap = false -- dont wrap lines
opt.mouse = 'a' -- allows to scroll with touchpad in two different splits just by hoevering the mouse in the split I wish to scroll
opt.cursorline = true -- highlight current line
opt.updatetime = 100

-- natural split opening
opt.splitbelow = true
opt.splitright = true

-- sound on errors
opt.visualbell = false
opt.errorbells = false

-- search
opt.hlsearch = true -- highlighted search result
opt.incsearch = true -- incremental search
opt.magic = true
opt.ignorecase = true -- ignore cases when searching
opt.smartcase = true -- however if we use a capital in search string we then consider case-sensitivity, ignorecase is disabled

-- folding
opt.foldenable = true
opt.foldlevelstart = 3
opt.foldmethod = 'indent' -- syntax

-- status bar
opt.laststatus = 2
opt.cmdheight = 1
opt.showcmd = true
opt.showmode = false -- turns off the --INSERT-- etc mode messages at very bottom
opt.ruler = true

-- Fonts, Encoding
-- encoding
opt.fileencoding = 'utf-8'
opt.encoding = 'utf-8'
opt.langmenu = 'en_US.utf-8'
vim.env.LANG = 'en_US.UTF-8'

-- reload gVim menu with UTF-8 encoding
vim.cmd([[source $VIMRUNTIME/delmenu.vim]])
vim.cmd([[source $VIMRUNTIME/menu.vim]])

-- fileformats
opt.formatoptions:append('Mm') -- for multi byte character
opt.formatoptions:append('crql')
opt.formatoptions:remove('t')
opt.fileformats:append('unix')
opt.fileformats:append('dos')
opt.fileformats:append('mac')

-- wildmode
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildoptions = "pum"

-- Tabs, Spaces and Indent handling
opt.expandtab = true -- expand tab to space
opt.tabstop = 2 -- tab displays as two spaces
opt.shiftwidth = 2 -- indentation for reindent operations (<< and >>)
opt.softtabstop = 2 -- tab in insert mode behaves as two spaces
opt.smarttab = true

-- tab length exceptions on some file types
vim.api.nvim_create_autocmd("FileType", {
	pattern = {"html", "htmldjango", "javascript", "php", "vue"},
	command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2"
})

-- directories for backup, swap, and undo
-- default path: ~/.local/share/nvim
local backupdir = vim.fn.expand("~/.cache/nvim/backups")
local directory = vim.fn.expand("~/.cache/nvim/tmp") -- swap files
local undodir = vim.fn.expand("~/.cache/nvim/undos")

-- create directories if they don't exist
local function create_dir(dir)
	if not vim.fn.isdirectory(dir) then
		os.execute("mkdir -p " .. dir)
	end
end

create_dir(backupdir)
create_dir(directory)
create_dir(undodir)

-- Better Backup, Swap and Undo storage settings
-- Uncomment the lines as per your requirement
-- opt.directory = directory
-- opt.backupdir = backupdir
-- opt.undodir = undodir
-- opt.backup = true -- overwrites previous backups instead of making new one
-- opt.undofile = true
