#! /usr/bin/env bash
set -e

is_linux() {
    if [[ "$(uname)" == "Linux" ]]; then
        return 0
    else
        return 1
    fi
}

is_mac() {
    if [[ "$(uname)" == "Darwin" ]]; then
        return 0
    else
        return 1
    fi
}

is_desktop_environment() {
    if is_mac; then
        return 0
    fi
    if [[ -n "$DESKTOP_SESSION" ]]; then
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

directory_present() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

linux_install() {
    if dpkg -l $1 > /dev/null 2>&1; then
        echo "$1 already installed"
    else
        echo "installing $1"
        sudo apt install $1 -y
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

macos_install() {
    if brew list $1 > /dev/null 2>&1; then
        echo "$1 already installed"
    else
        echo "installing $1"
        brew install $1
    fi
}


zsh_active() {
    if echo $SHELL | grep -q 'zsh'; then
        return 0
    else
        return 1
    fi
}

if is_linux; then
    echo "Linux OS detected..."
    linux_install "libevent-dev"
    linux_install "ncurses-dev"
    linux_install "build-essential"
    linux_install "bison"
    linux_install "pkg-config"
    linux_install "libfreetype6-dev"
    linux_install "libfontconfig1-dev"
    linux_install "libxcb-xfixes0-dev"
    linux_install "libxkbcommon-dev"
    linux_install "python3"
    linux_install "zsh"

    # dependencies for rofi, do not install
    # on servers
    if is_desktop_environment; then
        linux_install "flex"
        linux_install "libglib2.0-dev"
        linux_install "libxcb-util-dev"
        linux_install "libxcb-ewmh-dev"
        linux_install "libxcb-icccm4-dev"
        linux_install "libxcb-cursor-dev"
        linux_install "libxcb-imdkit-dev"
        linux_install "libxcb-xkb-dev"
        linux_install "libxcb-randr0-dev"
        linux_install "libxcb-xinerama0-dev"
        linux_install "libxkbcommon-x11-dev"
        linux_install "libpango1.0-dev"
        linux_install "libstartup-notification0-dev"
        linux_install "libgdk-pixbuf-2.0-dev"
    fi
elif is_mac; then
    echo "MacOS detected..."
    install_homebrew_if_missing
    macos_install "ninja"
    macos_install "cmake"
    macos_install "gettext"
    macos_install "bison"
    macos_install "libevent"
    macos_install "ncurses"
    macos_install "pkg-config"
    macos_install "automake"
    macos_install "zsh"
else
    echo "could not determine OS. Exiting."
    exit 1
fi

if zsh_active; then
    echo "zsh already default shell"
else
    echo "setting zsh as default shell"
    chsh -s $(which zsh)
fi

if directory_present "$HOME/.oh-my-zsh"; then
    echo "oh my zsh found"
else
    echo "installing oh my zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi


export PATH="$HOME/.local/bin:$PATH"

NEOVIM_INSTALL_PATH="$HOME/.local"
NEOVIM_SOURCE_PATH="$HOME/.neovim-src"
RBENV_INSTALL_PATH="$HOME/.rbenv"
PYENV_INSTALL_PATH="$HOME/.pyenv"
TPM_INSTALL_PATH="$HOME/.tmux/plugins/tpm"
TMUX_INSTALL_PATH="$HOME/.local"
TMUX_SOURCE_PATH="$HOME/tmux-src"
ALACRITTY_SOURCE_PATH="$HOME/alacritty-src"
ALACRITTY_INSTALL_PATH="$HOME/.local"
NVM_SOURCE_PATH="$HOME/.nvm"
STARSHIP_INSTALL_PATH="$HOME/.local/bin"
ROFI_INSTALL_PATH="$HOME/.local"

if [[ "$*" == *"--reinstall"* ]]; then
    echo "Reinstalling..."
    echo "removing alacritty"
    rm -rf $ALACRITTY_SOURCE_PATH
    rm -rf $ALACRITTY_INSTALL_PATH/bin/alacritty

    echo "removing tmux"
    rm -rf $TMUX_INSTALL_PATH/bin/tmux
    rm -rf $TMUX_SOURCE_PATH

    echo "removing neovim"
    rm -rf $NEOVIM_INSTALL_PATH/bin/nvim
    rm -rf $NEOVIM_SOURCE_PATH

    echo "removing rbenv"
    rm -rf $RBENV_INSTALL_PATH
    echo "removing pyenv"
    rm -rf $PYENV_INSTALL_PATH
    echo "removing tpm"
    rm -rf $TPM_INSTALL_PATH

    echo "removing nvm"
    rm -rf $NVM_SOURCE_PATH

    echo "removing starship"
    rm -rf $STARSHIP_INSTALL_PATH/starship

fi

if is_desktop_environment; then
    echo "Desktop environment detected..."
    if command_installed "rustup"; then
        echo "rustup found, skipping installation"
    else
        echo "installing rustup"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        export PATH="$HOME/.cargo/bin:$PATH"
        rustup override set stable
        rustup update stable
    fi

    if command_installed "alacritty"; then
        echo "alacritty found, not installing"
    else
        git clone https://github.com/alacritty/alacritty $ALACRITTY_SOURCE_PATH
        cd $ALACRITTY_SOURCE_PATH
        cargo build --release
        cp ./target/release/alacritty $ALACRITTY_INSTALL_PATH/bin
        if is_mac; then
            make app
            cp -r target/release/osx/Alacritty.app /Applications/
        fi
    fi

    # install rofi
    if command_installed "rofi"; then
        echo "rofi already found"
    else
        echo "installing rofi"
        cd ~
        mkdir rofi-release && cd rofi-release
        curl -LO https://github.com/davatorium/rofi/releases/download/1.7.5/rofi-1.7.5.tar.gz
        tar -xzvf rofi-1.7.5.tar.gz
        cd rofi-1.7.5
        mkdir build && cd build
        ../configure --prefix=$ROFI_INSTALL_PATH
        make
        make install
    fi
else
    echo "No desktop environment detected, skipping rustup and alacritty installation"
fi


if command_installed "tmux"; then
    echo "tmux found not installing"
else
    echo "installing tmux"
    git clone https://github.com/tmux/tmux.git $TMUX_SOURCE_PATH
    cd $TMUX_SOURCE_PATH
    sh autogen.sh
    if is_linux; then
        ./configure --prefix=$TMUX_INSTALL_PATH
    elif is_mac; then
        ./configure --prefix=$TMUX_INSTALL_PATH --enable-utf8proc
    fi
    make
    make install
fi

if command_installed "nvim"; then
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

export PATH="$RBENV_INSTALL_PATH/bin:$PATH"
if command_installed "rbenv"; then
    echo "rbenv directory found, not installing"
else
    echo "installing rbenv..."
    git clone https://github.com/rbenv/rbenv.git $RBENV_INSTALL_PATH
    git clone https://github.com/rbenv/ruby-build.git $RBENV_INSTALL_PATH/plugins/ruby-build
fi

if directory_present $TPM_INSTALL_PATH; then
    echo "tpm directory found, not installing"
else
    echo "installing tpm..."
    git clone https://github.com/tmux-plugins/tpm $TPM_INSTALL_PATH
fi

if directory_present $PYENV_INSTALL_PATH; then
    echo "pyenv directory found, not installing"
else
    echo "installing pyenv to $PYENV_INSTALL_PATH..."
    git clone https://github.com/pyenv/pyenv.git $PYENV_INSTALL_PATH
fi

if command_installed "starship"; then
    echo "starship found"
else
    curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir $STARSHIP_INSTALL_PATH
fi

if directory_present "$NVM_SOURCE_PATH"; then
    echo "nvm found"
else
    git clone https://github.com/nvim-sh/nvm ~/.nvm
fi
