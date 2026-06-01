function wtb -a branch_name base_ref -d 'make a new branch with worktrunk and zellij'
    set -l base_args
    if test -n "$base_ref"
        set base_args --base $base_ref
    end
    wt switch --no-cd -c $branch_name $base_args -x 'tmux-sessionizer {{ worktree_path }}'
end
