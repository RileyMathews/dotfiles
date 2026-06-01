function gcm -a branch_name -d 'make a new branch with worktrunk and zellij'
    wt switch -c (git_main_branch) -x 'tmux-sessionizer {{ worktree_path }}'
end
