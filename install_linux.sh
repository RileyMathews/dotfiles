git clone https://github.com/neovim/neovim.git ~/neovim-src
cd ~/neovim-src
rm -rf ./build/
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
make install
export PATH="$HOME/neovim/bin:$PATH"
