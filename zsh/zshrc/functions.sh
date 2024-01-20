get_current_tmux_session() {
    tmux display-message -p '#S'
}

get_current_tmux_window() {
    tmux display-message -p '#I'
}

get_current_tmux_pane() {
    tmux display-message -p '#P'
}

run_command_in_pane() {
    current_window=$(get_current_tmux_window);
    current_pane=$(get_current_tmux_pane);
    tmux send-keys -t $current_window.$current_pane "$1" C-m;
}

tdjango() {
    current_window=$(get_current_tmux_window);

    run_command_in_pane "psh";
    run_command_in_pane "nvim .";
    
    tmux split-window -v -p 20;
    run_command_in_pane "psh";
    run_command_in_pane "./manage.py runserver";

    tmux split-window -h -p 50;
    run_command_in_pane "psh";

    tmux select-pane -t $current_window.0;
}

trust() {
    current_window=$(get_current_tmux_window);

    run_command_in_pane "nvim .";
    
    tmux split-window -v -p 20;
    run_command_in_pane "cargo watch -x run -w src";

    tmux split-window -h -p 50;

    tmux select-pane -t $current_window.0;
}

fzt() {
    directory=$(find ~/code -type d -maxdepth 1 | fzf);
    basename=`basename $directory`;
    tmux new-session -s $basename -c $directory -d;
    # check if argument is passed
    if [ -n "$1" ]
    then
        tmux send-keys -t $basename.0 "$1" C-m;
    fi
    tmux attach-session -t $basename;
}

fztdj() {
    fzt "tdjango";
}

fztrust() {
    fzt "trust";
}
