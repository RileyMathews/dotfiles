function gcb -a branch_name -d 'make a new branch with worktrunk and zellij'
    wt switch --no-cd -c $branch_name -x 'tmux-sessionizer {{ worktree_path }}'
end
