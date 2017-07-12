let $PATH .='C:/Windows/SysWOW64/python27.dll'
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'mattn/emmet-vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'tpope/vim-surround'
Plugin 'Townk/vim-autoclose'
Plugin 'Chiel92/vim-autoformat'
Plugin 'lilydjwg/colorizer'
Plugin 'pangloss/vim-javascript'
Plugin 'Valloric/YoucompleteMe'
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'

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
" =======================================================================
" tabs and spaces handling
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2
set backspace=indent,eol,start

" tab length exceptions on some file types
autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2

" always show status bar
set ls=2

" incremental search
set incsearch
" highlighted search results
set hlsearch

" syntax highlight on
syntax on

" show line numbers
set number

" set encoding
let $LANG="zh_TW.UTF-8"
set langmenu=zh_tw.utf-8
set encoding=utf-8
set fileencoding=utf-8
" reload gVim menu with UTF-8 encoding
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" when scrolling, keep cursor 3 lines away from screen border
set scrolloff=3

" autocompletion of files and commands behaves like shell
" (complete only the common part, list the options that match)
set wildmode=list:longest

" better backup, swap and undos storage
set directory=~/.vim/dirs/tmp     " directory to place swap files in
set backup                        " make backup files
set backupdir=~/.vim/dirs/backups " where to put backup files
set undofile                      " persistent undos - undo after you re-open the file
set undodir=~/.vim/dirs/undos
set viminfo+=n~/.vim/dirs/viminfo 
" store yankring history file there too
let g:yankring_history_dir = '~/.vim/dirs/'

" create needed directories if they don't exist
if !isdirectory(&directory)
    call mkdir(&directory, "p")
endif
if !isdirectory(&backupdir)
    call mkdir(&backupdir, "p")
endif
if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

" Shortcut maps ------------------------

let mapleader = ","
" edit .vimrc
map <silent> <leader>ee :tabe ~/.vimrc<CR>
" toggle comment with emmet
map <silent> <leader>/ <C-y>/
" open a new tab
map <C-n> :tabnew<CR>
" escape ESC
imap jj <Esc>

" ======================================
" Plugins settings and mappings

" NERDTree ----------------------------- 

" toggle nerdtree display
map <F2> :NERDTreeToggle<CR>
" open nerdtree with the current file selected
nmap ,t :NERDTreeFind<CR>
" don't show these file types
let NERDTreeIgnore = ['\.pyc$', '\.pyo$']

" Autoformat ---------------------------
nmap <F3> :Autoformat<CR>

" Emmet --------------------------------

imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

" CtrlP --------------------------------

let g:ctrlp_map = ',e'  " file finder mapping
nmap ,g :CtrlPBufTag<CR> " tags (symbols) in current file finder mapping
nmap ,G :CtrlPBufTagAll<CR> " tags (symbols) in all files finder mapping
nmap ,f :CtrlPLine<CR> " general code finder in all files mapping
nmap ,m :CtrlPMRUFiles<CR> " recent files finder mapping
nmap ,c :CtrlPCmdPalette<CR> " commands finder mapping

" to be able to call CtrlP with default search text
function! CtrlPWithSearchText(search_text, ctrlp_command_end)
    execute ':CtrlP' . a:ctrlp_command_end
    call feedkeys(a:search_text)
endfunction

" same as previous mappings, but calling with current word as default text
nmap ,wg :call CtrlPWithSearchText(expand('<cword>'), 'BufTag')<CR>
nmap ,wG :call CtrlPWithSearchText(expand('<cword>'), 'BufTagAll')<CR>
nmap ,wf :call CtrlPWithSearchText(expand('<cword>'), 'Line')<CR>
nmap ,we :call CtrlPWithSearchText(expand('<cword>'), '')<CR>
nmap ,pe :call CtrlPWithSearchText(expand('<cfile>'), '')<CR>
nmap ,wm :call CtrlPWithSearchText(expand('<cword>'), 'MRUFiles')<CR>
nmap ,wc :call CtrlPWithSearchText(expand('<cword>'), 'CmdPalette')<CR>
" don't change working directory
let g:ctrlp_working_path_mode = 0
" ignore these files and folders on file finder
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn|node_modules)$',
  \ 'file': '\.pyc$\|\.pyo$',
  \ }

" Airline ------------------------------

let g:airline_powerline_fonts = 0
let g:airline_theme = 'bubblegum'
let g:airline#extensions#whitespace#enabled = 0

" YouCompleteMe ------------------------

let g:ycm_dont_warn_on_startup = 0
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1
let g:ycm_collect_identifiers_from_comments_and_strings = 1

let g:ycm_filetype_blacklist = {}

let g:ycm_key_list_select_completion   = ['<C-j>', '<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-k>', '<C-p>', '<Up>']

" Ultisnips ----------------------------

let g:UltiSnipsSnippetsDir='~/.vim/snippets'
let g:UltiSnipsEditSplit='vertical'
let g:UltiSnipsExpandTrigger           = '<tab>'
let g:UltiSnipsJumpForwardTrigger      = '<tab>'
let g:UltiSnipsJumpBackwardTrigger     = '<s-tab>'
"let g:UltiSnipsUsePythonVersion = 2
nnoremap <leader>ue :UltiSnipsEdit<CR>

" =======================================================

" Colorthemes --------------------------

" set dark background
set bg=dark

" use 256 colors when possible
if (&term =~? 'mlterm\|xterm\|xterm-256\|screen-256') || has('nvim')
	let &t_Co = 256
    "colorscheme fisa
    "colorscheme evening
    colorscheme jellybeans
else
    colorscheme delek
    "colorscheme jellybeans
endif

" colors for gvim
if has('gui_running')
    "colorscheme wombat
    colorscheme evening
endif
