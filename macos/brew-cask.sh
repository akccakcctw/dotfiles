#!/usr/bin/env bash

brew tap caskroom/cask

brew cask install font-hanamina
brew cask install font-noto-sans-cjk
brew cask install font-noto-serif-cjk
brew cask install google-chrome
brew cask install iterm2
brew cask install karabiner-elements
# brew cask install sourcetree
# brew cask install spotify
# brew cask install telegram
brew cask install vagrant
brew cask install virtualbox
brew cask install docker
brew cask install snipaste
# brew cask install visual-studio-code
# brew cask install vlc
# brew cask install xquartz

brew cask cleanup
brew cask doctor

