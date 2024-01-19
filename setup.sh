#! /usr/bin/env sh

echo "removing existing links"
rm -rf ~/.tmux.conf
rm -rf ~/.config/nvim
rm -rf ~/.zshrc
rm -rf ~/zshrc
rm -rf ~/.tmuxifier/layouts

echo "adding symlinks"
ln -s `pwd`/tmux/.tmux.conf ~/.tmux.conf
ln -s `pwd`/nvim ~/.config/nvim
ln -s `pwd`/zsh/.zshrc ~/.zshrc
ln -s `pwd`/zsh/zshrc ~/zshrc
ln -s `pwd`/tmuxifier/layouts ~/.tmuxifier/layouts
