#!/usr/bin/env bash

echo 'Deploying...'
cd "$(dirname "${BASH_SOURCE}")" # cd to directory of this script
git pull origin master

ORIG_DIR=linux
SOURCE_DIR=~/.dotfiles

mkdir -p $SOURCE_DIR

function deployFiles() {
  rsync --exclude ".git/" \
    --exclude ".DS_Store" \
    --exclude ".osx" \
    --exclude "deploy.sh" \
    --exclude "README.md" \
    --exclude "LICENSE" \
    -avh --no-perms ${ORIG_DIR}/* ${SOURCE_DIR}
}

function createSymlinks() {
  ln -si "${SOURCE_DIR}/$(basename $1)" ~/.$(basename $1) # create symbolic links
}

read -p "This may overwrite existing files in your HOME directory. Are you sure? (y/n) " -n 1
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
  deployFiles
  for file in ${SOURCE_DIR}/*; do
    createSymlinks ${file}
  done
fi

unset deployFiles
source ~/.bashrc
echo 'success!'

