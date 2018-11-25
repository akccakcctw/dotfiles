# dotfiles

My personal .files, tested and works well on my macOS (MacBook Pro) and ArchLinux (Surface Pro 4)


## Prerequisites

- Vim version 8.0+, with python supports
- vim-plug, the plugin manager for Vim
  + follow official README [here](https://github.com/junegunn/vim-plug)
- Git, if you want to keep syncing with new updates


## Optional

- ctags (for tags generation)


## Clone and Update

```sh
# I like to put it in ~/Projects/dotfiles
cd ~/Projects
git clone https://github.com/akccakcctw/dotfiles.git 

# Update
cd dotfiles
git pull
```


## Deploy

Execute `deploy.sh` (you'd better read it first).

```sh
. deploy.sh
```


## Features

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

- [Autoformat](https://github.com/Chiel92/vim-autoformat)
  + `<Leader>FF`
- [CtrlP](https://github.com/ctrlpvim/ctrlp.vim)
  + `<Leader>f` for CtrlPLine
- [EasyAlign](https://github.com/junegunn/vim-easy-align)
- [EditorConfig](https://github.com/editorconfig/editorconfig-vim)
- [Emmet](https://github.com/mattn/emmet-vim)
  + enabled in html, css, scss, pug, vue, php files
  + expand: `<C-e>,`
  + wrap: select then `<C-e>,`
  + next edit position: `<C-e>n`
  + previous edit position: `<C-e>N`
  + select current tag: `<C-e>d`
  + delete tag: `<C-e>k`
  + merge multiple lines: `<C-e>m`
- [NERDTree](https://github.com/scrooloose/nerdtree)
  + NERDTreeToggle: `<F5>` or `<C-b>`
- [tComment](https://github.com/tomtom/tcomment_vim)
	+ toggle comment with `<Leader>cc` in normal mode
	+ select then `<Leader>cc` for inline comment
  + select then `<Leader>c<Space>` for block comment
- [Tagbar](https://github.com/majutsushi/tagbar)
  + toggle tagbar: `<F8>`
- [Vim-buffergator](https://github.com/jeetsukumaran/vim-buffergator)
	+ `<Leader>b` to open a window listing all buffers
	+ `<C-v>` to edit the selected buffer in a new vertical split
	+ `<C-s>` to edit the selected buffer in a new horizontal split
	+ `<C-t>` to edit the selected buffer in a new tab
- [vim-tags](https://github.com/szw/vim-tags)
	+ generate tags for the project (using ctags) `:TagGenerate!`
- [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)
  + `<Leader>tm` to start it (or typing `:TableModeToggle`)
- [UltiSnips](https://github.com/SirVer/ultisnips)
- [YouCompleteMe](https://github.com/Valloric/YouCompleteMe)
- [ALE](https://github.com/w0rp/ale)
- [WindowSwap](https://github.com/wesQ3/vim-windowswap)

#### Language Server

[What is Language Server?](https://langserver.org/)

- Client
  + [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim)
- Servers (install manually)
  + JavaScript: [sourcegraph/javascript-typescript-langserver](https://github.com/sourcegraph/javascript-typescript-langserver)
    ```
    npm i -g javascript-typescript-langserver
    ```
  + PHP: [felixfbecker/php-language-server](https://github.com/felixfbecker/php-language-server)
    ```
    composer global require felixfbecker/language-server
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

