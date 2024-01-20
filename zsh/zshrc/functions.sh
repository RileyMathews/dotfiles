get_current_tmux_window() {
    tmux display-message -p '#I'
}

get_current_tmux_pane() {
    tmux display-message -p '#P'
}

run_command_in_pane() {
    echo "testing";
    current_window=$(get_current_tmux_window);
    current_pane=$(get_current_tmux_pane);
    tmux send-keys -t $current_window.$current_pane "$1" C-m;
}

tdjango() {
    echo "testing";
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
