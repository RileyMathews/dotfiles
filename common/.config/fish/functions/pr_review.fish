function pr_review -a directory -a pr_number
    set -l cwd (pwd)
    cd $directory

    set -l branch_name (gh pr view $pr_number --json headRefName --jq .headRefName)
    if test $status -ne 0
        cd $cwd
        return 1
    end

    set -l base_branch (gh pr view $pr_number --json baseRefName --jq .baseRefName)
    if test $status -ne 0
        cd $cwd
        return 1
    end

    wt switch --no-cd pr:$pr_number
    if test $status -ne 0
        cd $cwd
        return 1
    end

    set -l worktree_path (wt list --format=json | jq -r --arg branch "$branch_name" '.[] | select(.branch == $branch and .path) | .path' | string collect)
    if test $status -ne 0
        cd $cwd
        return 1
    end

    cd $cwd

    if test -z "$worktree_path"
        echo "Could not resolve worktree path for PR $pr_number ($branch_name)"
        return 1
    end

    git -C $worktree_path fetch origin $base_branch
    if test $status -ne 0
        return 1
    end

    set -l session_name (basename $worktree_path)
    set -l created_session 0

    if not tmux has-session -t $session_name 2>/dev/null
        set created_session 1
        tmux new-session -d -s $session_name -c $worktree_path -n shell
    end

    if test $created_session -eq 1
        tmux new-window -t $session_name:1 -c $worktree_path
        tmux new-window -t $session_name:2 -c $worktree_path
        tmux send-keys -t $session_name:1 "nvim '+lua require(\"ghlite\").open_pr($pr_number)'" C-m
        tmux send-keys -t $session_name:2 "opencode --agent review --prompt 'generate a summary for this PR'" C-m
    end

    if test -z "$TMUX"
        tmux attach-session -t $session_name
    else
        tmux switch-client -t $session_name
    end
end
