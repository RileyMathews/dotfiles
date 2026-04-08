function git_main_branch
    if git show-ref --verify --quiet refs/heads/main
        echo main
    else
        echo master
    end
end
