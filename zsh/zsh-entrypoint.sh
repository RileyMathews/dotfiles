secret_file="~/.config/zsh/.zshrc.secret"
secret_file_expanded="$(eval echo $secret_file)"

export EDITOR="nvim"

if [[ -e "$secret_file_expanded" ]]; then
    source "$secret_file_expanded"
fi


for file in ~/.config/zsh/*; do
    if [ "$(basename $file)" != "zsh-entrypoint.sh" ]; then
        source $file
    fi
done

eval "$(starship init zsh)"
source $HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
