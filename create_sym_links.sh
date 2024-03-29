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
rm -rf ~/.Xresources
rm -rf ~/.xsessionrc
rm -rf ~/.config/rofi
rm -rf ~/.config/aerospace
rm -rf ~/.config/i3status/config

if directory_present ~/.config; then
    echo "config directory already present"
else
    echo "creating config directory"
    mkdir ~/.config
fi

echo "adding symlinks"
ln -s `pwd`/tmux/.tmux.conf ~/.tmux.conf
ln -s `pwd`/nvim ~/.config/nvim
ln -s `pwd`/zsh/.zshrc ~/.zshrc
ln -s `pwd`/zsh/zshrc ~/zshrc
mkdir -p ~/.config/i3
ln -s `pwd`/i3/config ~/.config/i3/config
mkdir -p ~/.config/i3status
ln -s `pwd`/i3status/config ~/.config/i3status/config
mkdir -p ~/.config/alacritty
ln -s `pwd`/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml
ln -s `pwd`/starship/starship.toml ~/.config/starship.toml
ln -s `pwd`/x11/.Xresources ~/.Xresources
ln -s `pwd`/x11/.xsessionrc ~/.xsessionrc
ln -s `pwd`/rofi ~/.config/rofi
ln -s `pwd`/aerospace ~/.config/aerospace

echo "All done. You might need to change your shell to zsh and restart to see all changes"
