# dotfiles

My personal .files with [chezmoi](https://www.chezmoi.io/), tested and works well on macOS (MacBook Pro) and ArchLinux (Surface Pro 4)


## Prerequisites

- [chezmoi](https://www.chezmoi.io/docs/install/)
- [Neovim](https://neovim.io/), or Vim version 8.0+, with python supports
- vim-plug, the plugin manager for Vim
  + follow official README [here](https://github.com/junegunn/vim-plug)
- Git, if you want to keep syncing with new updates
- [oh-my-zsh](https://ohmyz.sh/)


## Optional

- ctags (for tags generation)


## Usage

```sh
# init
chezmoi init https://github.com/akccakcctw/dotfiles.git

# update
chezmoi update
```


## Features

### Tmux

#### Tmux Plugins

- [tpm](https://github.com/tmux-plugins/tpm)
- [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat)
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank)


### Vim

mapping leader key to `,`.

- tabs
  + ~~open a new tab: `<C-n>`~~
  + switch to next tab: `<Leader>n`
- split window
  + split horizontal: `<C-\>`
  + split window navigations: `<C-Left>`, `<C-Down>`, `<C-Up>`, `<C-Right>`
  + switch between vertical/horizontal split: `<Leader>E`, `<Leader>I`
- no highlight search result: `<Leader>/`
- toggle wrap: `<F2>`
- increase/decrease number under the cursour: `+`, `-`
- move text line up/down: `<C-j>`, `<C-k>`
- avoid the escape key: `jj`
- save a file as root: `<Leader>WW`
- strip trailing whitespace: `<Leader>ss`
- edit .vimrc: `<leader>ee`


#### Vim Plugins

- [vim-autoformat](https://github.com/Chiel92/vim-autoformat)
  + `<Leader>FF`
- [indentLine](https://github.com/Yggdroot/indentLine)
- [vim-gitgutter](https://github.com/airblade/vim-gitgutter)
- [vim-import-cost](https://github.com/yardnsm/vim-import-cost)
- [scss-syntax.vim](https://github.com/cakebaker/scss-syntax.vim)
- [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)
  + `<Leader>tm` to start it (or typing `:TableModeToggle`)
- [vim-pug](https://github.com/digitaltoad/vim-pug)
- [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim)
- [vim-json](https://github.com/elzr/vim-json)
- [vim-go](https://github.com/fatih/vim-go)
- [vim-snippets](https://github.com/honza/vim-snippets)
- [tidy-html5](https://github.com/htacg/tidy-html5)
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
- [tender](https://github.com/jacoborus/tender.vim)
- [vim-buffergator](https://github.com/jeetsukumaran/vim-buffergator)
	+ `<Leader>b` to open a window listing all buffers
	+ `<C-v>` to edit the selected buffer in a new vertical split
	+ `<C-s>` to edit the selected buffer in a new horizontal split
	+ `<C-t>` to edit the selected buffer in a new tab
- [fzf](https://github.com/junegunn/fzf)
- [fzf.vim](https://github.com/junegunn/fzf.vim)
- [gv.vim](https://github.com/junegunn/gv.vim)
- [vim-easy-align](https://github.com/junegunn/vim-easy-align)
- [patchreview-vim](https://github.com/junkblocker/patchreview-vim)
- [typescript-vim](https://github.com/leafgarland/typescript-vim)
- [colorizer](https://github.com/lilydjwg/colorizer)
  + removed, it makes vim slow
- [tagbar](https://github.com/majutsushi/tagbar)
  + toggle tagbar: `<F8>`
- [emmet-vim](https://github.com/mattn/emmet-vim)
  + enabled in html, css, scss, pug, vue, php files
  + expand: `<C-e>,`
  + wrap: select then `<C-e>,`
  + next edit position: `<C-e>n`
  + previous edit position: `<C-e>N`
  + select current tag: `<C-e>d`
  + delete tag: `<C-e>k`
  + merge multiple lines: `<C-e>m`
- [vim-indent-guides](https://github.com/nathanaelkane/vim-indent-guides)
- [vim-javascript](https://github.com/pangloss/vim-javascript)
- [vim-markdown](https://github.com/plasticboy/vim-markdown)
- [vim-vue](https://github.com/posva/vim-vue)
- [vim-devicons](https://github.com/ryanoasis/vim-devicons)
  + choose a [Nerd Font compatible font](https://github.com/ryanoasis/nerd-fonts#font-installation) for your terminal to see fancy icons
- [nerdtree](https://github.com/scrooloose/nerdtree)
  + NERDTreeToggle: `<C-b>`
- [vim-tags](https://github.com/szw/vim-tags)
	+ generate tags for the project (using ctags) `:TagGenerate!`
- [vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors)
- [vim-code-dark](https://github.com/tomasiser/vim-code-dark)
- [tcomment_vim](https://github.com/tomtom/tcomment_vim)
	+ toggle comment with `<Leader>cc` in normal mode
	+ select then `<Leader>cc` for inline comment
  + select then `<Leader>c<Space>` for block comment
- [vim-fugitive](https://github.com/tpope/vim-fugitive)
- [vim-surround](https://github.com/tpope/vim-surround)
- [vim-airline](https://github.com/vim-airline/vim-airline)
- [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
- [vdebug](https://github.com/vim-vdebug/vdebug)
- [ale](https://github.com/dense-analysis/ale)
- [vim-windowswap](https://github.com/wesQ3/vim-windowswap)
- [coc.nvim](https://github.com/neoclide/coc.nvim)
- [json5.vim](https://github.com/gutenye/json5.vim)


#### Coc Extensions

[Wiki: Using coc extensions](https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions)

- [coc-eslint](https://github.com/neoclide/coc-eslint)
- [coc-highlight](https://github.com/neoclide/coc-highlight)
- [coc-json](https://github.com/neoclide/coc-json)
- [coc-css](https://github.com/neoclide/coc-css)
- [coc-html](https://github.com/neoclide/coc-html)
- [coc-phpls](https://github.com/marlonfan/coc-phpls)
    + prerequisites: intelephense
    + settings in coc-settings.json
- [coc-tsserver](https://github.com/neoclide/coc-tsserver)
- [coc-vetur](https://github.com/neoclide/coc-vetur)


#### Language Servers

[What is Language Server?](https://langserver.org/)

- Client
  + [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim)
- Servers (install manually)
  + JavaScript: [sourcegraph/javascript-typescript-langserver](https://github.com/sourcegraph/javascript-typescript-langserver)
    ```
    npm i -g javascript-typescript-langserver
    ```
  + PHP: [intelephense](https://www.npmjs.com/package/intelephense)
    ```
    npm i -g intelephense

    ```
  + Dockerfile: [rcjsuen/dockerfile-language-server-nodejs](https://github.com/rcjsuen/dockerfile-language-server-nodejs)
    ```
    npm i -g dockerfile-language-server-nodejs
    ```
  + Vue: [vuejs/vetur/server](https://github.com/vuejs/vetur/tree/master/server)
    ```
    npm i -g vue-language-server
    ```

read [linux/vimrc](https://github.com/akccakcctw/dotfiles/blob/master/linux/vimrc) for more details.

