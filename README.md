# dotfiles

My personal .files, tested and works well on my macOS (MacBook Pro) and ArchLinux (Surface Pro 4)

## Prerequisites

- Vim version 8.0+, with python supports
- vim-plug, the plugin manager for Vim
	+ follow official README [here](https://github.com/junegunn/vim-plug)
- Git, if you want to keep syncing with new updates

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

