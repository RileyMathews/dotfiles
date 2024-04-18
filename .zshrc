secret_file="~/.zshrc.secret"
secret_file_expanded="$(eval echo $secret_file)"

export EDITOR="nvim"

if [[ -e "$secret_file_expanded" ]]; then
    source "$secret_file_expanded"
fi


for file in ~/zshrc/*; do
    if [ "$(basename $file)" != "init.sh" ]; then
        source $file
    fi
done

eval "$(starship init zsh)"
source $HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
