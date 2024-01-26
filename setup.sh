#! /usr/bin/env sh

echo "removing existing links"
rm -rf ~/.tmux.conf
rm -rf ~/.config/nvim
rm -rf ~/.zshrc
rm -rf ~/zshrc
rm -rf ~/.config/i3
rm -rf ~/.config/alacritty

echo "adding symlinks"
ln -s `pwd`/tmux/.tmux.conf ~/.tmux.conf
ln -s `pwd`/nvim ~/.config/nvim
ln -s `pwd`/zsh/.zshrc ~/.zshrc
ln -s `pwd`/zsh/zshrc ~/zshrc
mkdir -p ~/.config/i3
ln -s `pwd`/i3/config ~/.config/i3/config
mkdir -p ~/.config/alacritty
ln -s `pwd`/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
