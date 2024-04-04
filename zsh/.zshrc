# keep things like secret values and computer
# specific settings in a non version controlled file
if [[ -n $DISPLAY ]]; then
    secret_file="~/.zshrc.secret"
    secret_file_expanded="$(eval echo $secret_file)"

    unset SHELL
    export EDITOR="nvim"

    if [[ -e "$secret_file_expanded" ]]; then
        source "$secret_file_expanded"
    fi


    for file in ~/zshrc/*; do
        if [ "$(basename $file)" != "init.sh" ]; then
            source $file
        fi
    done

    # Start tmux session named 'default' if not already running
    if ! tmux has-session -t 'default' 2> /dev/null; then
        tmux new-session -s 'default' -d
    fi

    # Attach to the 'default' session

    if [[ -z "${TMUX}" ]]; then
        tmux attach -t 'default'
    fi

    eval "$(starship init zsh)"
    source $HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
