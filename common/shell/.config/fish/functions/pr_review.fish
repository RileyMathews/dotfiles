function pr_review -a directory -a pr_number
    echo "args:"
    echo $directory
    echo $pr_number

    set -l cwd (pwd)
    cd $directory
    git checkout (git_main_branch)
    git fetch
    git pull

    gh pr checkout $pr_number

    set -l session_name "review_$pr_number"

    tmux new-session -d -s $session_name -c $directory
    tmux new-window -t $session_name
    tmux send-keys -t $session_name:1 "nvim '+lua require(\"ghlite\").open_pr($pr_number)'" C-m
    tmux send-keys -t $session_name:2 "opencode" C-m
    cd $cwd
    tmux attach -t $session_name
end
