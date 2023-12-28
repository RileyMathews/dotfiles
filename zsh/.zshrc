export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="af-magic"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# keep things like secret values and computer
# specific settings in a non version controlled file
secret_file="~/.zshrc.secret"
secret_file_expanded="$(eval echo $secret_file)"
if [[ -e "$secret_file_expanded" ]]; then
    source "$secret_file_expanded"
fi
