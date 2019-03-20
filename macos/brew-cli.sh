#!/usr/bin/env bash

brew update

brew install bash-completion
brew install bat
brew install binutils
brew install brew-cask-completion
brew install ccat
brew install cmake
brew install coreutils
brew install cscope
brew install ctags
brew install findutils --with-default-names
brew install fzf
brew install git
brew install git-lfs
brew install gnu-sed --with-default-names
brew install gnupg
brew install go
brew install grep --with-default-names
brew install gzip
brew install htop
brew install hugo
brew install imagemagick
brew install imgcat
brew install lynx
brew install macvim
brew install neovim
brew install nmap
brew install node
brew install openssh
brew install p7zip
brew install python
brew install python3
brew install rename
brew install ripgrep
brew install socat
brew install tidy-html5
brew install tldr
brew install tmux
brew install tree
brew install vim --with-override-system-vi --with-python3
brew install wget
brew install woff2
brew install xz
brew install zsh

brew cleanup --force
brew prune
brew doctor

