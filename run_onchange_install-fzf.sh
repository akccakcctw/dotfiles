#!/bin/sh
# Install fzf via junegunn's installer if ~/.fzf.zsh / ~/.fzf.bash are missing.
# chezmoi previously tracked these files directly, but they're machine-specific
# build artifacts of `~/.fzf/install --all` — managing them as content drifts on
# every install. This script delegates to the upstream installer instead.
set -eu

# Arch installs fzf via pacman; no ~/.fzf.* needed.
[ -f /etc/arch-release ] && exit 0

if [ -f "$HOME/.fzf.zsh" ] && [ -f "$HOME/.fzf.bash" ]; then
  exit 0
fi

if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
fi

"$HOME/.fzf/install" --all
