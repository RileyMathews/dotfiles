function find-code --description 'Pick a code directory and switch tmux sessions'
    set -l code_root $HOME/code
    set -l config_root $HOME/.config
    set -l worktrees_root $HOME/worktrees
    set -l roots $code_root $config_root $worktrees_root
    set -l tab (printf '\t')
    set -l existing_roots

    for root in $roots
        if test -d "$root"
            set -a existing_roots "$root"
        end
    end

    set -l fzf_command fzf
    if set -q TMUX
        set fzf_command fzf-tmux -p 80%,70%
    end

    set -l preview_command "bash -lc 'directory=\$1; ls -la --color=always \"\$directory\"' bash {3}"
    if command -q eza
        set preview_command "bash -lc 'directory=\$1; eza --all --git --icons --color=always \"\$directory\"' bash {3}"
    end

    set -l selection (begin
            set -l tmux_paths

            if command -q tmux
                for line in (tmux list-sessions -F "#{session_name}$tab#{session_path}" 2>/dev/null)
                    set -l fields (string split --max 1 $tab -- "$line")
                    set -l session_name $fields[1]
                    set -l session_path $fields[2]

                    if test -z "$session_name" -o -z "$session_path"
                        continue
                    end

                    set -a tmux_paths "$session_path"
                    printf 'tmux%s\033[34m\033[39m %s%s%s%s%s\n' $tab "$session_name" $tab "$session_path" $tab "$session_name"
                end
            end

            if test (count $existing_roots) -gt 0
                for directory in (fd -H -d 1 -t d . $existing_roots 2>/dev/null)
                    if contains -- "$directory" $tmux_paths
                        continue
                    end

                    printf 'dir%s\033[36m\033[39m %s%s%s%s\n' $tab "$directory" $tab "$directory" $tab
                end
            end
        end | $fzf_command \
        --no-sort --ansi \
        --delimiter "$tab" --with-nth 2 \
        --border-label ' find-code ' --prompt '⚡  ' \
        --header '   tmux   directory  enter switch  tab/btab move' \
        --bind 'tab:down,btab:up' \
        --preview-window 'right:55%' \
        --preview "$preview_command")

    if test -z "$selection"
        return 0
    end

    set -l selection_fields (string split --max 3 $tab -- "$selection")
    set -l kind $selection_fields[1]
    set -l target $selection_fields[3]
    set -l session_name $selection_fields[4]

    switch "$kind"
        case tmux
            if set -q TMUX
                tmux switch-client -t "$session_name"
            else
                tmux attach-session -t "$session_name"
            end
        case dir
            tmux-sessionizer "$target"
    end
end
