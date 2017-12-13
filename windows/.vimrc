set nocompatible              " be iMproved, required
filetype off                  " required

" ## Map leader {{{
let mapleader = ','
let maplocalleader = ','
let g:mapleader = ','
let g:maplocalleader = ','
" }}}

" ## Plugin (Vundle) {{{
set rtp+=~/.vim/bundle/Vundle.vim " set the runtime path to include Vundle and initialize
call vundle#begin()

Plugin 'Chiel92/vim-autoformat'
Plugin 'Townk/vim-autoclose'
Plugin 'VundleVim/Vundle.vim'
Plugin 'digitaltoad/vim-pug'
Plugin 'editorconfig/editorconfig-vim'
Plugin 'honza/vim-snippets'
Plugin 'jlanzarotta/bufexplorer'
Plugin 'junegunn/gv.vim' " Git commit browser
Plugin 'junegunn/vim-easy-align'
Plugin 'lilydjwg/colorizer' " colorize the color in the form #rgb...
Plugin 'maksimr/vim-jsbeautify'
Plugin 'mattn/emmet-vim'
Plugin 'pangloss/vim-javascript'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-fugitive' " Git wrapper
Plugin 'tpope/vim-surround'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
" filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" === Plugin Settings below ===

" --- NERDTree --- {{{
map <F2> :NERDTreeToggle<CR> " toggle nerdtree display
nmap ,t :NERDTreeFind<CR> " open nerdtree with the current file selected

" dont show these file types
let NERDTreeIgnore = ['\.pyc$', '\.pyo$']
" }}}

" --- NERD Commenter --- {{{
let g:NERDSpaceDelims = 1
let g:NERDRemoveExtraSpaces = 1
" }}}

" --- editorconfig plugin --- {{{
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
" }}}

" --- Autoformat --- {{{
nmap <F3> :Autoformat<CR>
" }}}

" --- BufExplorer --- {{{
let g:bufExplorerSortBy = 'name'
let g:bufExplorerShowRelativePath = 1
let g:bufExplorerShowNoName = 1
" }}}

" --- Emmet --- {{{
let g:user_emmet_mode='in' " only enable in input/normal mode
let g:user_emmet_install_global = 0 " enable just for html/css
let g:user_emmet_leader_key='<C-y>'
let g:user_emmet_expandabbr_key='<Tab>'
autocmd FileType html,css EmmetInstall
" }}}

" --- Airline --- {{{
let g:airline_powerline_fonts = 0
let g:airline_theme = 'bubblegum'
let g:airline#extensions#whitespace#enabled = 0
" }}}

" --- easy-align --- {{{
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}

" }}}

" ## UI settings {{{
set number " show line numbers
set showmatch " show matching brackets when text indicator is over them
set scrolloff=3 " when scrolling, keep cursor 3 lines away from screen border
set timeout
set ttimeoutlen=10
set virtualedit=block " the cursor can be positioned where there is no actual character in the visual mode
set nolazyredraw " don't redraw while executing macros
set whichwrap+=<,>,[,]
set nostartofline

" --- sound on errors --- {{{
set novisualbell
set noerrorbells
" }}}

" --- tabs, spaces and indent handling --- {{{
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set ai " auto indent
set wrap " wrap lines
set backspace=indent,eol,start
" }}}

" --- search --- {{{
set hlsearch " highlighted search results
set incsearch " incremental search
set magic " magic for Regular Expression
set ignorecase " case insensitive
set smartcase
" }}}

" --- folding --- {{{
set foldenable
set foldlevelstart=10
set fdm=syntax
" }}}

" --- status bar --- {{{
set laststatus=2 " always show status bar
set cmdheight=1 " command bar height
set showcmd " display what command was typed
set noshowmode " mode already show on the status bar
set ruler " always show current position
" }}}

" --- colorscheme --- {{{
syntax on " enable syntax highlight
set background=dark

" use 256 colors if possible
if (&term =~? 'mlterm\|xterm\|xterm-256\|screen-256') || has('nvim')
  let &t_Co = 256
  colorscheme fisa
else
  colorscheme delek
endif

" for gvim
if has('gui_running')
  colorscheme evening
endif
" }}}

" }}}

" ## Fonts, Encoding {{{
" set encoding
let $LANG="zh_TW.UTF-8"
set langmenu=zh_tw.utf-8
set encoding=utf-8
set fileencoding=utf-8

" reload gVim menu with UTF-8 encoding
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" fileformats (line ending characters)
set ffs=unix,dos,mac
" }}}

" tab length exceptions on some file types
autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2

" autocompletion of files and commands behaves like shell
" (complete only the common part, list the options that match)
set wildmode=list:longest

" ## backup, swap and undos storage {{{
" set nobackup
" set nowb
" set noswapfile
set directory=~/.vim/dirs/tmp     " directory to place swap files in
set backup                        " make backup files
set backupdir=~/.vim/dirs/backups " where to put backup files
set undofile                      " persistent undos - undo after you re-open the file
set undodir=~/.vim/dirs/undos
set viminfo+=n~/.vim/dirs/viminfo

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


" ## Key Mappings {{{

map <silent> <leader>ee :tabe ~/.vimrc<CR> " edit .vimrc
nnoremap <C-n> :tabnew<CR> " open a new tab

" increase and decrease number under the cursor
nnoremap + <C-a>
nnoremap - <C-x>

" move text with CTRL+[jk]
nnoremap <C-j> :m+<CR>:echo "move line down"<CR>
nnoremap <C-k> :m-2<CR>:echo "move line up"<CR>
vnoremap <C-j> :m'>+<CR>:echo "move block down"<CR>gv
vnoremap <C-k> :m'<-2<CR>:echo "move block up"<CR>gv

" esc
nnoremap <C-e> <ESC>
inoremap <C-e> <ESC>
vnoremap <C-e> <ESC>
snoremap <C-e> <ESC>
inoremap jj <Esc> 
" }}}

" ## Languages {{{
"  --- python --- {{{
let python_highlight_all = 1
let python_no_parameter_highlight = 1
" }}}

" }}}