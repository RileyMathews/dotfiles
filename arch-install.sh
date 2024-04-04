#! /bin/zsh

sudo pacman -S \
	ttf-hack-nerd \
	tmux \
	neovim \
	starship \
	alacritty \
	pyenv \
	direnv \
	zoxide \
	fzf \
	ripgrep

LOCAL_SHARE_DIR="$HOME/.local/share"

ZSH_SYNTAX_HIGHLIGTING_DIRECTORY=$LOCAL_SHARE_DIR/zsh-syntax-highlighting
if directory_present $ZSH_SYNTAX_HIGHLIGTING_DIRECTORY; then
    echo "zsh syntax highlighting found"
else
    echo "installing zsh syntax highligting plugin"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_SYNTAX_HIGHLIGTING_DIRECTORY
fi
