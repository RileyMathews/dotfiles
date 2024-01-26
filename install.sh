#! /usr/bin/env bash

if [[ "$(uname)" == "Linux" ]]; then
    echo "Linux OS detected..."
    sudo apt install libevent-dev ncurses-dev build-essential bison pkg-config
elif [[ "$(uname)" == "Darwin" ]]; then
    echo "MacOS detected..."
else
    echo "could not determine OS. Exiting."
    exit 1
fi

NEOVIM_INSTALL_PATH="$HOME/neovim"
NEOVIM_SOURCE_PATH="$HOME/neovim-src"
RBENV_INSTALL_PATH="$HOME/.rbenv"
PYENV_INSTALL_PATH="$HOME/.pyenv"
TPM_INSTALL_PATH="$HOME/.tmux/plugins/tpm"
TMUX_INSTALL_PATH="$HOME/tmux"
TMUX_SOURCE_PATH="$HOME/tmux-src"

if [[ "$*" == *"--reinstall"* ]]; then
    echo "Reinstalling..."
    echo "removing tmux"
    rm -rf $TMUX_INSTALL_PATH
    rm -rf $TMUX_SOURCE_PATH

    echo "removing neovim"
    rm -rf $NEOVIM_INSTALL_PATH
    rm -rf $NEOVIM_SOURCE_PATH

    echo "removing rbenv"
    rm -rf $RBENV_INSTALL_PATH
    echo "removing pyenv"
    rm -rf $PYENV_INSTALL_PATH
    echo "removing tpm"
    rm -rf $TPM_INSTALL_PATH
fi

if [ -d "$TMUX_INSTALL_PATH" ]; then
    echo "tmux found not installing"
else
    echo "installing tmux"
    git clone https://github.com/tmux/tmux.git $TMUX_SOURCE_PATH
    cd $TMUX_SOURCE_PATH
    sh autogen.sh
    ./configure --prefix $TMUX_INSTALL_PATH
    make
    make install
fi

if [ -d "$NEOVIM_INSTALL_PATH" ]; then
    echo "nvim found in path, not installing"
else
    echo "nvim not found, installing"
    git clone https://github.com/neovim/neovim.git $NEOVIM_SOURCE_PATH
    cd $NEOVIM_SOURCE_PATH
    rm -rf ./build/
    make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$NEOVIM_INSTALL_PATH"
    make install
    export PATH="$NEOVIM_INSTALL_PATH/bin:$PATH"
    rm -rf ~/neovim-src
    cd ~
fi

if [ -d "$RBENV_INSTALL_PATH" ]; then
    echo "rbenv directory found, not installing"
else
    echo "installing rbenv..."
    git clone https://github.com/rbenv/rbenv.git $RBENV_INSTALL_PATH
    git clone https://github.com/rbenv/ruby-build.git $RBENV_INSTALL_PATH/plugins/ruby-build
fi

if [ -d "$TPM_INSTALL_PATH" ]; then
    echo "tpm directory found, not installing"
else
    echo "installing tpm..."
    git clone https://github.com/tmux-plugins/tpm $TPM_INSTALL_PATH
fi

if [ -d "$PYENV_INSTALL_PATH" ]; then
    echo "pyenv directory found, not installing"
else
    echo "installing pyenv to $PYENV_INSTALL_PATH..."
    git clone https://github.com/pyenv/pyenv.git $PYENV_INSTALL_PATH
fi
