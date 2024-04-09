directory_present() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

echo "removing existing links"
rm -rf ~/.tmux.conf
rm -rf ~/.config/nvim
rm -rf ~/.zshrc
rm -rf ~/zshrc
rm -rf ~/.config/i3
rm -rf ~/.config/alacritty
rm -rf ~/.config/starship.toml
rm -rf ~/.config/aerospace
rm -rf ~/.config/rofi
rm -rf ~/.config/i3status/config
rm -rf ~/.config/qtile/config.py
rm -rf ~/.config/polybar

if directory_present ~/.config; then
    echo "config directory already present"
else
    echo "creating config directory"
    mkdir ~/.config
fi

echo "adding symlinks"
ln -s `pwd`/.tmux.conf ~/.tmux.conf
ln -s `pwd`/.config/nvim ~/.config/nvim
ln -s `pwd`/.zshrc ~/.zshrc
ln -s `pwd`/zshrc ~/zshrc
mkdir ~/.config/i3
ln -s `pwd`/.config/i3/config ~/.config/i3/config
mkdir -p ~/.config/alacritty
ln -s `pwd`/.config/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
ln -s `pwd`/.config/starship/starship.toml ~/.config/starship.toml

ln -s `pwd`/.config/rofi ~/.config/rofi
ln -s `pwd`/aerospace ~/.config/aerospace
mkdir -p ~/.config/qtile
ln -s `pwd`/qtile/config.py ~/.config/qtile/config.py
ln -s `pwd`/polybar ~/.config/polybar

echo "All done. You might need to change your shell to zsh and restart to see all changes"
