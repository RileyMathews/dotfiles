#! /bin/zsh

sudo pacman -S --needed \
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

yay -S --needed \
	rbenv

LOCAL_SHARE_DIR="$HOME/.local/share"
ZSH_SYNTAX_HIGHLIGTING_DIRECTORY=$LOCAL_SHARE_DIR/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_SYNTAX_HIGHLIGTING_DIRECTORY
git clone https://github.com/nvm-sh/nvm ~/.nvm
