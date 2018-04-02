#!/usr/bin/env bash

brew update

brew install bash-completion
brew install binutils
brew install brew-cask-completion
brew install ccat
brew install cmake
brew install coreutils
brew install cscope
brew install ctags
brew install docker
brew install docker-compose
brew install docker-machine
brew install docker-machine-driver-xhyve
brew install findutils
brew install git
brew install gnu-sed
brew install gnupg
brew install go
brew install grep
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
brew install ripgrep
brew install socat
brew install tldr
brew install tmux
brew install tree
brew install vim
brew install wget
brew install woff2
brew install xhyve
brew install xz
brew install zsh

brew cleanup --force
brew prune
brew doctor

