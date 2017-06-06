set nocompatible              " be iMproved, required
filetype off                  " required

" vim-plug
call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'mattn/emmet-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-surround'
Plug 'Townk/vim-autoclose'
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'
Plug 'Chiel92/vim-autoformat'
Plug 'lilydjwg/colorizer'
Plug 'jacoborus/tender' "colorscheme
Plug 'altercation/vim-colors-solarized' "colorscheme

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
" Put your non-Plugin stuff after this line

" tabs and spaces handling
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" tab length exceptions on some file types
autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2

" avoid the escape key
:imap jj <Esc>

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

" set dark background
set bg=dark

" use 256 colors when possible
if (&term =~? 'mlterm\|xterm\|xterm-256\|screen-256') || has('nvim')
    let &t_Co = 256
    "colorscheme tender
    colorscheme solarized
else
    colorscheme delek
endif

" colors for gvim
if has('gui_running')
    colorscheme evening
endif

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
if !isdirectory(&backupdir)
    call mkdir(&backupdir, "p")
endif
if !isdirectory(&directory)
    call mkdir(&directory, "p")
endif
if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

" ============================================================================
" Plugins settings and mappings

" NERDTree ----------------------------- 

" toggle nerdtree display
map <F3> :NERDTreeToggle<CR>
" open nerdtree with the current file selected
nmap ,t :NERDTreeFind<CR>
" don;t show these file types
let NERDTreeIgnore = ['\.pyc$', '\.pyo$']

" Emmet ------------------------------

"imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")
"let g:user_emmet_expandabbr_key = '<Tab>'
autocmd filetype *html* imap <c-_> <c-y>/
autocmd filetype *html* map <c-_> <c-y>/

" CtrlP ------------------------------

" file finder mapping
let g:ctrlp_map = ',e'
" tags (symbols) in current file finder mapping
nmap ,g :CtrlPBufTag<CR>
" tags (symbols) in all files finder mapping
nmap ,G :CtrlPBufTagAll<CR>
" general code finder in all files mapping
nmap ,f :CtrlPLine<CR>
" recent files finder mapping
nmap ,m :CtrlPMRUFiles<CR>
" commands finder mapping
nmap ,c :CtrlPCmdPalette<CR>
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
" set airline theme
let g:airline_theme = 'tender'
"let g:airline_theme = 'bubblegum'
let g:airline#extensions#whitespace#enabled = 0

"enable tender airline theme
let g:tender_airline = 1
