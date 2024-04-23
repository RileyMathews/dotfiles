#! /bin/bash

echo "setting up neovim"
rm -rf ~/.config/nvim
ln -s `pwd`/nvim ~/.config/nvim

echo "setting up alacritty"
rm -rf ~/.config/alacritty
ln -s `pwd`/alacritty ~/.config/alacritty

echo "setting up aerospace"
rm -rf ~/.config/aerospace
ln -s `pwd`/aerospace ~/.config/aerospace

echo "setting up starship"
rm -rf ~/.config/starship.toml
ln -s `pwd`/starship/starship.toml ~/.config/starship.toml

echo "setting up tmux"
rm -rf ~/.tmux.conf
ln -s `pwd`/tmux/tmux.conf ~/.tmux.conf

echo "setting up zsh"
rm -rf ~/.zshrc
rm -rf ~/.config/zsh
ln -s `pwd`/zsh ~/.config/zsh
ln -s `pwd`/.zshrc ~/.zshrc
