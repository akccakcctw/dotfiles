# dotfiles

My personal .files with [chezmoi](https://www.chezmoi.io/), tested and works well on macOS (MacBook Pro) and ArchLinux (Intel NUC 8i7HVK)


## Prerequisites

- Git, if you want to keep syncing with new updates
- [chezmoi](https://www.chezmoi.io/docs/install/)
- [Neovim](https://neovim.io/), or Vim version 8.0+, with python supports
- [LazyVim](https://github.com/LazyVim/LazyVim): the plugin manager for Vim
- [delta](https://github.com/dandavison/delta): for Git diff
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

Use [tpm](https://github.com/tmux-plugins/tpm) to manage plugins:

- [tmux-copycat](https://github.com/tmux-plugins/tmux-copycat)
- [tmux-yank](https://github.com/tmux-plugins/tmux-yank)


### WezTerm

Cross-platform config (`dot_wezterm.lua`) — a single file that auto-detects the OS via `wezterm.target_triple`. Atom One Dark theme with a Warp-like look, plus a status bar showing the current directory's Node version (resolved by [mise](https://mise.jdx.dev/)).

Keybindings differ per platform on purpose. On macOS `Cmd` is free for the GUI app, but on Linux plain `Ctrl` is reserved by the shell (`Ctrl+C`, `Ctrl+D`, `Ctrl+W`, …), so a direct `Cmd`→`Ctrl` swap would clobber core terminal keys. Linux therefore follows the `Ctrl+Shift` / `Ctrl+Alt` convention (and avoids `Super`, which desktop environments grab):

| Action | macOS | Linux |
| --- | --- | --- |
| Split left/right | `Cmd+D` | `Ctrl+Shift+D` |
| Split top/bottom | `Cmd+Shift+D` | `Ctrl+Alt+D` |
| Close pane | `Cmd+W` | `Ctrl+Shift+W` |
| Quick Select (copy URLs/paths/hashes) | `Cmd+Shift+U` | `Ctrl+Alt+U` (built-in `Ctrl+Shift+Space` also works) |
| Tab navigator / filter tabs | `Cmd+Shift+T` | `Ctrl+Alt+T` |
| Rename tab (empty input restores auto title) | `Cmd+Shift+E` | `Ctrl+Shift+E` |
| Move focus between panes | `Cmd+Alt+Arrow` | `Ctrl+Alt+Arrow` |
| Open link under cursor | `Cmd+Click` | `Ctrl+Click` |

Mouse wheel scrolling is rebound to 5 lines per notch (WezTerm's default is 3) via `SCROLL_LINES` — there is no built-in setting for scroll speed, so the wheel events are remapped to `ScrollByLine`. The binding sets `alt_screen = false` so full-screen programs (vim, less, lazygit) keep their own scroll handling.

Other platform-specific bits handled in the same file: the mise binary path, `macos_window_background_blur` (macOS only), and font fallbacks (Nerd Font → DejaVu Sans Mono → monospace).

Requires a [Nerd Font](https://www.nerdfonts.com/) (e.g. Hack Nerd Font) for the Node icon in the status bar.


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

##### Syntax Highlighting

- [chezmoi.vim](https://github.com/alker0/chezmoi.vim)
- [editorconfig-vim](https://github.com/editorconfig/editorconfig-vim)
- [vim-mjml](https://github.com/amadeus/vim-mjml)

##### UI

- [indentLine](https://github.com/Yggdroot/indentLine)
- [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)
  + NvimTreeToggle: `<C-b>`
- [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)
- [vim-devicons](https://github.com/ryanoasis/vim-devicons)
  + choose a [Nerd Font compatible font](https://github.com/ryanoasis/nerd-fonts#font-installation) for your terminal to see fancy icons
- [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
- [vim-airline](https://github.com/vim-airline/vim-airline)
- [vim-indent-guides](https://github.com/nathanaelkane/vim-indent-guides)
- [vim-gitgutter](https://github.com/airblade/vim-gitgutter)

##### Color Schemes

- [vim-code-dark](https://github.com/tomasiser/vim-code-dark)

##### Snippets

- [vim-snippets](https://github.com/honza/vim-snippets)

##### Others

- [vim-autoformat](https://github.com/Chiel92/vim-autoformat)
  + `<Leader>FF`
- [vim-import-cost](https://github.com/yardnsm/vim-import-cost)
- [vim-table-mode](https://github.com/dhruvasagar/vim-table-mode)
  + `<Leader>tm` to start it (or typing `:TableModeToggle`)
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
- [vim-tags](https://github.com/szw/vim-tags)
	+ generate tags for the project (using ctags) `:TagGenerate!`
- [vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors)
- [tcomment_vim](https://github.com/tomtom/tcomment_vim)
	+ toggle comment with `<Leader>cc` in normal mode
	+ select then `<Leader>cc` for inline comment
  + select then `<Leader>c<Space>` for block comment
- [vim-fugitive](https://github.com/tpope/vim-fugitive)
- [vim-surround](https://github.com/tpope/vim-surround)
- [vdebug](https://github.com/vim-vdebug/vdebug)
- [ale](https://github.com/dense-analysis/ale)
- [mason.nvim](https://github.com/williamboman/mason.nvim)
- [vim-windowswap](https://github.com/wesQ3/vim-windowswap)


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


#### nvim-treesitter

https://github.com/nvim-treesitter/nvim-treesitter
