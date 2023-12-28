#! /usr/bin/env sh

echo "removing existing links"
rm -rf ~/.tmux.conf
rm -rf ~/.config/nvim

echo "adding symlinks"
ln -s `pwd`/tmux/.tmux.conf ~/.tmux.conf
ln -s `pwd`/nvim ~/.config/nvim
