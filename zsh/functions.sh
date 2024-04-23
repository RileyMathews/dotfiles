gacp() {
    git add .
    git status
    echo -n "continue? (y/n): "
    read response
    if [ "$response" = "y" ]
    then
        echo -n "Enter commit message: "
        read message
        git commit -m "$(git symbolic-ref --short HEAD) -- $message"
        git push
    else
        git restore --staged .
    fi
}

tsg() {
    directory=$(ls ~/code | fzf)
    _tmux_switch_or_activate ~/code/$directory $directory
}

dote() {
    _tmux_switch_or_activate ~/dotfiles "dotfiles"
}

_tmux_switch_or_activate() {
    directory=$1
    session_name=$2
    if [ -n "$TMUX" ]; then
        command="switch"
    else
        command="attach"
    fi

    if tmux has-session -t $session_name 2>/dev/null; then
    else
        tmux new-session -d -s $session_name -c $directory
    fi
    tmux $command -t $session_name
}
