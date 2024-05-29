#! /bin/bash

echo "setting up neovim"
rm -rf ~/.config/nvim
ln -s `pwd`/nvim ~/.config/nvim

echo "setting up alacritty"
rm -rf ~/.config/alacritty
ln -s `pwd`/alacritty ~/.config/alacritty

echo "setting up dunst"
rm -rf ~/.config/dunst
ln -s `pwd`/dunst ~/.config/dunst

echo "setting up eww"
rm -rf ~/.config/eww
ln -s `pwd`/eww ~/.config/eww

echo "setting up i3"
rm -rf ~/.config/i3
ln -s `pwd`/i3 ~/.config/i3

echo "setting up rofi"
rm -rf ~/.config/rofi
ln -s `pwd`/rofi ~/.config/rofi

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

echo "setting up sxhkd"
rm -rf ~/.config/sxhkd
ln -s `pwd`/sxhkd ~/.config/sxhkd

echo "setting up picom"
rm -rf ~/.config/picom
ln -s `pwd`/picom ~/.config/picom

echo "setting up i3status"
rm -rf ~/.config/i3status
ln -s `pwd`/i3status ~/.config/i3status

echo "setting up bin scripts"
rm -rf ~/.local/bin/update-checker
ln -s `pwd`/localbin/update-checker ~/.local/bin/update-checker
