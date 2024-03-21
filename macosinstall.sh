#! /usr/bin/env bash
set -e
SCRIPT_DIR=`pwd`

LOCAL_SHARE_DIR="$HOME/.local/share"

directory_present() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

command_installed() {
    if command -v "$1" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

install_homebrew_if_missing() {
    if command_installed "brew"; then
        echo "brew found, skipping installation"
    else
        echo "installing homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

echo "MacOS detected..."
install_homebrew_if_missing
brew install \
     zoxide \
     neovim \
     pyenv \
     rbenv \
     nvm \
     starship \
     tmux
brew install --no-quarantine --cask nikitabobko/tap/aerospace
brew install --cask alacritty

export PATH="$HOME/.local/bin:$PATH"
TPM_INSTALL_PATH="$HOME/.tmux/plugins/tpm"

if directory_present $TPM_INSTALL_PATH; then
    echo "tpm directory found, not installing"
else
    echo "installing tpm..."
    git clone https://github.com/tmux-plugins/tpm $TPM_INSTALL_PATH
fi

ZSH_SYNTAX_HIGHLIGTING_DIRECTORY=$LOCAL_SHARE_DIR/zsh-syntax-highlighting
if directory_present $ZSH_SYNTAX_HIGHLIGTING_DIRECTORY; then
    echo "zsh syntax highlighting found"
else
    echo "installing zsh syntax highligting plugin"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_SYNTAX_HIGHLIGTING_DIRECTORY
fi

cd $SCRIPT_DIR
echo `pwd`

bash ./create_sym_links.sh
