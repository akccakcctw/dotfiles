" =======================================
"                   VIM
" Author: Rex Tsou<akccakccwww@gmail.com>
" =======================================
" ## General {{{
set history=500
set shell=$SHELL
set ttyfast

" use the OS clipboard by default
if has('macunix')
  set clipboard=unnamed " mac
else
  set clipboard+=unnamedplus " linux
endif

if !has('nvim')
  set nocompatible
  if &term =~ '^screen\|^tmux' && exists('$TMUX')
    if &term =~ '256color'
      set term=xterm-256color
    else
      set term=xterm
    endif
  endif
  if &term =~ '256color'
    set t_ut=
  endif
  if has('termguicolors')
		" set Vim-specific sequences for RGB colors (https://github.com/vim/vim/issues/993)
    let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"

		" enable true colors
		set termguicolors
  endif
endif

if has('nvim')
  if has('macunix')
    let g:python3_host_prog = '/usr/local/bin/python3'
    let g:node_host_prog = '/usr/local/lib/node_modules/neovim/bin/cli.js'
  else
    let g:python3_host_prog = '/usr/bin/python3'
    let g:node_host_prog = '/usr/lib/node_modules/neovim/bin/cli.js'
  endif
endif
" }}}

" ## Map leader {{{
let mapleader = ','
let maplocalleader = ','
let g:mapleader = ','
let g:maplocalleader = ','
" }}}

" ## Plugin manager (vim-plug) {{{
call plug#begin('~/.vim/plugged')

" ### syntax
Plug 'alker0/chezmoi.vim'
Plug 'amadeus/vim-mjml', { 'for': 'mjml' }
Plug 'cakebaker/scss-syntax.vim', { 'for': [ 'scss', 'sass' ]}
Plug 'digitaltoad/vim-pug', { 'for': 'pug' }
Plug 'editorconfig/editorconfig-vim'
Plug 'elzr/vim-json'
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'gutenye/json5.vim', { 'for': 'json5' }
Plug 'leafgarland/typescript-vim', { 'for': 'ts' }
Plug 'pangloss/vim-javascript'
Plug 'plasticboy/vim-markdown'
Plug 'posva/vim-vue', { 'for': 'vue' }

" ### treesitter
Plug 'RRethy/nvim-treesitter-textsubjects'
Plug 'danymat/neogen' " annotation generator (treesitter)
Plug 'numToStr/Comment.nvim'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

" ### LSP
Plug 'dense-analysis/ale' " check syntax with LSP support
Plug 'neoclide/coc.nvim', { 'commit': '9332d2ab1154dedc9dbcd3e1c873886abaf061a6' } " {'branch': 'release'}

" ### git
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/gv.vim', { 'on': 'GV' } " Git commit browser
Plug 'tpope/vim-fugitive' " Git wrapper

" ### GPT
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'dpayne/CodeGPT.nvim'

" ### uncategorized
Plug 'Chiel92/vim-autoformat'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'Yggdroot/indentLine'
Plug 'codegram/vim-codereview' " GitHub PR Code Review
Plug 'dhruvasagar/vim-table-mode', { 'for': [ 'markdown', 'txt' ] }
Plug 'honza/vim-snippets'
Plug 'htacg/tidy-html5'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
Plug 'jacoborus/tender' " colorscheme
Plug 'jeetsukumaran/vim-buffergator'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'junkblocker/patchreview-vim' " GitHub PR Code Review
Plug 'majutsushi/tagbar'
Plug 'mattn/emmet-vim', { 'for': [ 'html', 'css', 'scss', 'pug', 'vue', 'php', 'javascript' ] }
Plug 'maxmellon/vim-jsx-pretty'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'szw/vim-tags'
Plug 'terryma/vim-multiple-cursors'
Plug 'tomasiser/vim-code-dark' " colorscheme
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'wesQ3/vim-windowswap'
Plug 'yardnsm/vim-import-cost', { 'do': 'npm install', 'on': 'ImportCost' }

call plug#end()            " required
"
" Brief help
" :PlugInstall      - Install plugins
" :PlugUpdate       - Install or update plugins
" :PlugClean[!]     - Remove unused directories (bang version will clean without prompt)
" :PlugUpgrade      - Upgrade vim-plug itself
" :PlugStatus       - Check the status of plugins
" :PlugDiff         - Examine changes from the previous update and the pending changes
" :PlugSnapshot[!] [output path] - Generate script for restoring the current snapshot of the plugins
"
" see https://github.com/junegunn/vim-plug for more informations
" =====
" Plugins settings and mappings

" --- NERDTree --- {{{
nnoremap <C-b> :NERDTreeToggle<CR>
nnoremap ,t :NERDTreeFind<CR> " open nerdtree with the current file selected

" don't show these file types
let NERDTreeIgnore = ['\.pyc$', '\.pyo$']
" }}}


" --- Comment.nvim --- {{{
" JoosepAlviste/nvim-ts-context-commentstring
lua <<EOF
require('ts_context_commentstring').setup {
  enable_autocmd = false,
}
require('Comment').setup({
	pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
	ignore = '^$',
	toggler = {
		line = '<Leader>cc',
		block = '<Leader>c<Space>',
	},
	---LHS of operator-pending mappings in NORMAL and VISUAL mode
	opleader = {
		line = '<Leader>cc',
		block = '<Leader>c<Space>',
	},
	extra = {
		above = '<Leader>cO',
		below = '<Leader>co',
		eol = '<Leader>cA',
	},
})
EOF
" }}}

" --- Ale --- {{{
" lint after 1000ms after changes are made both on insert mode and normal mode
let g:ale_lint_on_text_changed = 'always'
let g:ale_lint_delay = 1000
" let g:ale_fix_on_save = 1

" use nice symbols for errors and warnings
let g:ale_sign_error = '✗ '
let g:ale_sign_warning = '⚠ '

let g:ale_fixers = {
  \ '*': ['remove_trailing_lines', 'trim_whitespace'],
  \ 'javascript': ['eslint'],
	\ 'vue': ['eslint'],
  \ }
let g:ale_linter_aliases = {
	\ 'vue': ['javascript', 'html', 'scss'],
	\ }
"  }}}

" --- coc.nvim --- {{{
function! CheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! ShowDocumentation()
	if CocAction('hasProvider', 'hover')
		call CocActionAsync('doHover')
	else
		call feedkeys('K', 'in')
	endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <silent> <Leader>ld <Plug>(coc-definition)
nmap <silent> <C-]> <Plug>(coc-definition)
nmap <silent> <Leader>ly <Plug>(coc-type-definition)
nmap <silent> <Leader>lr <Plug>(coc-references)
nmap <silent> <Leader>li <Plug>(coc-implementation)
" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>
" Symbol renaming
nmap <Leader>rn <Plug>(coc-rename)
" ctrl-space to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()
" <Tab>: completion
inoremap <silent><expr> <Tab>
	\ coc#pum#visible() ? coc#pum#next(1):
	\ CheckBackSpace() ? "\<Tab>" :
	\ coc#refresh()
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <C-k>
  \ coc#pum#visible() ? coc#_select_confirm() :
  \ "\<C-k>"
let g:coc_snippet_next = '<tab>'
" <S-Tab>: completion back
inoremap <expr><S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
" }}}
" --- editorconfig plugin --- {{{
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
" }}}

" --- nvim-treesitter --- {{{
lua <<EOF
require'nvim-treesitter.configs'.setup {
	-- A list of parser names, or "all" (the five listed parsers should always be installed)
	ensure_installed = { "c", "lua", "vim", "vimdoc", "query" },

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	-- List of parsers to ignore installing (or "all")
	ignore_install = {},

	highlight = {
		enable = true,

		-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
		-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
		-- the name of the parser)
		-- list of language that will be disabled
		disable = {},

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = '<CR>',
			scope_incremental = '<TAB>',
			node_incremental = '<CR>',
			node_decremental = '<S-TAB>',
		},
	},
	tree_docs = {
		enable = true,
	},
	textsubjects = {
		enable = true,
		prev_selection = ',', -- (Optional) keymap to select the previous selection
		keymaps = {
			['.'] = 'textsubjects-smart',
			[';'] = 'textsubjects-container-outer',
			-- ['i;'] = 'textsubjects-container-inner',
			['i;'] = { 'textsubjects-container-inner', desc = "Select inside containers (classes, functions, etc.)" },
		},
	},
	textobjects = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				-- You can optionally set descriptions to the mappings (used in the desc parameter of
				-- nvim_buf_set_keymap) which plugins like which-key display
				["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
				-- You can also use captures from other query groups like `locals.scm`
				["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
			},
			-- You can choose the select mode (default is charwise 'v')
			--
			-- Can also be a function which gets passed a table with the keys
			-- * query_string: eg '@function.inner'
			-- * method: eg 'v' or 'o'
			-- and should return the mode ('v', 'V', or '<c-v>') or a table
			-- mapping query_strings to modes.
			selection_modes = {
				['@parameter.outer'] = 'v', -- charwise
				['@function.outer'] = 'V', -- linewise
				['@class.outer'] = '<c-v>', -- blockwise
			},
			-- If you set this to `true` (default is `false`) then any textobject is
			-- extended to include preceding or succeeding whitespace. Succeeding
			-- whitespace has priority in order to act similarly to eg the built-in
			-- `ap`.
			--
			-- Can also be a function which gets passed a table with the keys
			-- * query_string: eg '@function.inner'
			-- * selection_mode: eg 'v'
			-- and should return true of false
			include_surrounding_whitespace = true,
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = { query = "@class.outer", desc = "Next class start" },
				--
				-- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
				["]o"] = "@loop.*",
				-- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
				--
				-- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
				-- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
				["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
				["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
			-- Below will go to either the start or the end, whichever is closer.
			-- Use if you want more granular movements
			-- Make it even more gradual by adding multiple queries and regex.
			goto_next = {
				["]d"] = "@conditional.outer",
			},
			goto_previous = {
				["[d"] = "@conditional.outer",
			}
		},
	},
}
EOF
" }}}

" --- neogen --- {{{
lua <<EOF
require('neogen').setup {
	enabled = true,
	javascript = {
		template = {
			annotation_convention = 'jsdoc',
		},
	},
	typescript = {
		template = {
			annotation_convention = 'tsdoc',
		},
	},
	php = {
		template = {
			annotation_convention = 'phpdoc',
		},
	},
}

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<Leader>nf", ":lua require('neogen').generate({ type = 'func' })<CR>", opts)

EOF
" }}}

" --- vim-json --- {{{
" Disable Plugin indentLine's conceal
" https://github.com/elzr/vim-json/issues/23#issuecomment-40293049
let g:indentLine_concealcursor=""
"  }}}

" --- Autoformat --- {{{
" (,FF)
" nnoremap <Leader>FF :Autoformat<CR>

" only format the selected part (use node.js package "js-beautify")
autocmd Filetype html,vue vnoremap <Leader>FF :'<,'>!js-beautify --type html --editorconfig<CR>
autocmd Filetype css,scss vnoremap <Leader>FF :'<,'>!js-beautify --type css --editorconfig<CR>
autocmd Filetype javascript vnoremap <Leader>FF :'<,'>!js-beautify --type js --editorconfig<CR>
" }}}

" --- Emmet --- {{{
let g:user_emmet_leader_key='<C-e>'
" let g:user_emmet_mode='in' " only enable in Input/Normal mode
let g:user_emmet_install_global = 0 " enable just for HTML/CSS
let g:user_emmet_settings = {
\ 'javascript': {
\   'extends': 'jsx',
\ },
\}

autocmd filetype html,css,scss,pug,vue,php,javascript EmmetInstall
"autocmd filetype *html* inoremap <A-/> <C-y>/
"autocmd filetype *html* vnoremap <A-/> <C-y>/
" }}}

" --- Tagbar --- {{{
nnoremap <F8> :Tagbar<CR>
" }}}

" --- FZF --- {{{
nmap <Leader>f :GFiles<CR>
nmap <Leader>F :Files<CR>
nmap <Leader>l :BLines<CR>
nmap <Leader>L :Lines<CR>
nmap <Leader>a :Rg<Space>
" }}}

" --- EasyAlign --- {{{
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}

" --- Indent Guildes --- {{{
let g:indent_guides_start_level = 2
let g:indent_guides_auto_colors = 0
let g:indent_guides_default_mapping = 0 " (toggle IndentGuides with <Leader>ig)
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=black ctermbg=black
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=233
" }}}

" --- Airline --- {{{
let g:airline_powerline_fonts = 0
let g:airline_theme = 'tender'
let g:airline#extensions#whitespace#enabled = 0

" enable tender airline theme
let g:tender_airline = 1
" }}}

" --- IndentLine --- {{{
let g:indentLine_char = '¦'
let g:indentLine_color_term = 236
" let g:indentLine_enabled = 0
" }}}

" --- vim-markdown --- {{{
let g:vim_markdown_conceal = 0
" }}}

" --- vim-vue --- {{{
autocmd BufEnter *.vue syntax sync fromstart
" }}}

" --- vim-table-mode --- {{{
function! s:isAtStartOfLine(mapping)
  let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

inoreabbrev <expr> <bar><bar>
  \ exists(':TableModeEnable') && <SID>isAtStartOfLine('\|\|') ?
  \ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
inoreabbrev <expr> __
  \ exists(':TableModeDisable') && <SID>isAtStartOfLine('__') ?
  \ '<c-o>:silent! TableModeDisable<cr>' : '__'

" For Markdown-compatible tables
let g:table_mode_corner = '|'
" }}}

" --- Colorizer --- {{{
nmap <Leader>ttc <Plug>Colorizer
" }}}

" }}}

" ## Wildmode {{{
" autocompletion of files and commands behaves like shell
" (complete only the common part, list the options that match)
set wildmode=list:longest
" }}}

" ## Tabs, Spaces and Indent handling {{{

set expandtab " expand tab to be space
" set noexpandtab
set tabstop=2 " make Tabs display as wide as 2 Spaces
set shiftwidth=2 " 2 columns text is indented with the reindent operations (<< and >>)
set softtabstop=2 " 2 columns vim uses when hitting Tab in insert mode
set smarttab

" tab length exceptions on some file types
autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType php setlocal shiftwidth=2 tabstop=2 softtabstop=2
" }}}

" ## Better Backup, Swap and Undo storage {{{
" set directory=~/.vim/dirs/tmp     " directory to place swap files in
" set backup                        " make backup files
" set backupdir=~/.vim/dirs/backups " where to put backup files
" set undofile                      " persistent undos - undo after you re-open the file
" set undodir=~/.vim/dirs/undos
" set viminfo+=n~/.vim/dirs/viminfo
" store yankring history file there too
let g:yankring_history_dir = '~/.vim/dirs/'

" create needed directories if they don't exist
if !isdirectory(&backupdir)
  call mkdir(&backupdir, "p")
endif
if !isdirectory(&directory)
  call mkdir(&directory, "p")
endif
if !isdirectory(&undodir)
  call mkdir(&undodir, "p")
endif
" }}}

" ## UI settings {{{
set number
set relativenumber
set showmatch
set scrolloff=3 " when scrolling, keep cursor 3 lines away from screen border
set timeout
set ttimeoutlen=10
set virtualedit=block
set nolazyredraw
set whichwrap+=<,>,[,]
set nostartofline
set autoread " auto read when a file is changed from the outside
set backspace=indent,eol,start
set autoindent
set nowrap " wrap lines
set mouse=a
set cursorline " highlight current line
set updatetime=100

" support mouse resize split inside tmux
if !has('nvim')
  if has('mouse_sgr')
    set ttymouse=sgr
  else
    set ttymouse=xterm2
  endif
endif

" --- Colorscheme --- {{{
syntax on
set bg=dark

" use 256 colors when possible
if (&term =~? 'mlterm\|xterm\|xterm-256\|screen-256') || has('nvim')
  let &t_Co = 256
  let g:solarized_termtrans = 1 " get rid of the grey background"
  colorscheme codedark
else
  colorscheme delek
endif

if has('gui_running')
  colorscheme codedark
  set guifont=Consolas:h18 " for Windows
  set guifont=monospace\ 18 " for Linux
  set guifont=Monaco:h18 " for macOS
endif

hi Folded ctermfg=59
" }}}

" --- natural split opening --- {{{
set splitbelow
set splitright
"  }}}

" --- let alt key can be mapped as <M-*> --- {{{
" set winaltkeys=no
" for i in range(65,90) + range(97,122)
  " let c = nr2char(i)
  " exec "map \e".c." <M-".c.">"
  " exec "map! \e".c." <M-".c.">"
" endfor
" }}}

" --- sound on errors --- {{{
set novisualbell
set noerrorbells
" }}}

" --- search --- {{{
set hlsearch " highlighted search results
set incsearch " incremental search
set magic
set ignorecase
set smartcase
" }}}

" --- folding --- {{{
set foldenable
set foldlevelstart=3
set foldmethod=indent " syntax
" }}}

" --- status bar  --- {{{
set laststatus=2
set cmdheight=1
set showcmd
set noshowmode
set ruler
" }}}


" }}}

" ## Fonts, Encoding {{{
" set encoding
set fileencoding=utf-8
set encoding=utf-8
set langmenu=en_US.utf-8
let $LANG='en_US.UTF-8'

" reload gVim menu with UTF-8 encoding
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" fileformats
set fo+=Mm " for multi byte character
set fo+=crql
set fo-=t
set ffs=unix,dos,mac
" }}}

" ## Key Mappings {{{

" edit .vimrc
nnoremap <silent> <Leader>ee :tabe $MYVIMRC<CR>
nnoremap <silent> <Leader>so :source $MYVIMRC<CR>

" open a new tab
" nnoremap <C-n> :tabnew<CR>

" switch to next tab
noremap <Leader>n :tabnext<CR>
noremap <Leader>p :tabprevious<CR>

" split window
" horizontal, same as <C-w>v
nnoremap <C-\> :vsp<CR>

" split window navigations
nnoremap <C-Left> <C-w>h
nnoremap <C-Down> <C-w>j
nnoremap <C-Up> <C-w>k
nnoremap <C-Right> <C-w>l

" switch between vertical/horizontal split
nnoremap <Leader>E :windo wincmd K<CR>
nnoremap <Leader>I :windo wincmd H<CR>

" no highlight search result
nnoremap <Leader>/ :nohl<CR>

" toggle wrap
noremap <F2> :set wrap! wrap?<CR>

" increase and decrease number under the cursor
nnoremap + <C-a>
nnoremap - <C-x>

" move text with CTRL+[jk]
nnoremap <C-j> :m+<CR>:echo "move line down"<CR>
nnoremap <C-k> :m-2<CR>:echo "move line up"<CR>
" inoremap <C-j> <Esc>:m+<CR>:echo "move line down"<CR>gi
" inoremap <C-k> <Esc>:m-2<CR>:echo "move line up"<CR>gi
vnoremap <C-j> :m'>+<CR>:echo "move block down"<CR>
vnoremap <C-k> :m'<-2<CR>:echo "move block up"<CR>

" avoid the escape key
inoremap jj <Esc>

" fix syntax highlighting
noremap <F12> <Esc>:syntax sync fromstart<CR>
inoremap <F12> <C-o>:syntax sync fromstart<CR>

" exit terminal mode
tnoremap <Esc> <C-\><C-n>

" }}}

" ## Functions {{{

" Strip trailing whitespace (,ss)
function! StripWhitespace()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  :%s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfunction
noremap <Leader>ss :call StripWhitespace()<CR>

" Save a file as root (,WW)
noremap <Leader>WW :w !sudo tee % > /dev/null<CR>

command EslintFix execute '!npx eslint % --fix'
command StylelintFix execute '!npx stylelint % --fix'

" }}}

" autoread while file change
au FocusGained,BufEnter * :checktime

" vim:fdm=marker:foldlevel=0

