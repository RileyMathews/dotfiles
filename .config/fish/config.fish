if status is-interactive
    # Commands to run in interactive sessions can go here
end

set EDITOR "nvim"
set BROWSER "brave"
set GH_BROWSER "brave"
set KEYTIMEOUT 1
set XDG_DATA_DIRS "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/riley/.local/share/flatpak/exports/share"

fish_add_path ~/.local/bin
fish_add_path ~/.local/scripts
fish_add_path ~/.local/python-scripts
fish_add_path ~/.screenlayout
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.cabal/bin
fish_add_path ~/.ghcup/bin
fish_add_path /usr/local/go/bin
fish_add_path ~/go/bin

abbr mpr "python manage.py runserver"
abbr mpmm "python manage.py makemigrations"
abbr mpm "python manage.py migrate"
abbr mp "python manage.py"
abbr zso "source ~/.zshrc"
abbr psh 'source "$(poetry env info --path)"/bin/activate'

abbr be 'bundle exec'
abbr ber 'bundle exec rails'
abbr bers 'bundle exec rails s'

abbr dcb 'docker compose build'
abbr dcud 'docker compose up -d'
abbr dcd 'docker compose down'
abbr dclf 'docker compose logs -f'

abbr fd 'cd $(find * -type d | fzf)'
abbr fh 'cd ~ && cd $(find * -type d -maxdepth 2 | fzf)'

abbr gst 'git status'
abbr gaa 'git add .'
abbr gcmsg 'git commit -m'
abbr gp 'git push'
abbr gpsup 'git push --set-upstream origin $(git branch --show-current)'
abbr gl 'git pull'
abbr gco 'git checkout'
abbr gcb 'git checkout -b'
abbr gcm 'git checkout $(git_main_branch)'

abbr l 'ls -lah --color'
abbr ls 'ls --color'

abbr k 'kubectl'
abbr ka 'kubectl apply -f'
abbr kar 'kubectl apply --recursive -f'

abbr n 'nvim'

abbr upd 'update-arch'

abbr ap 'ansible-playbook'

abbr s7 'system76-power'

abbr tss 'sudo tailscale switch'

set -Ux PYENV_ROOT $HOME/.pyenv
test -d $PYENV_ROOT/bin; and fish_add_path $PYENV_ROOT/bin

fnm env --use-on-cd --shell fish | source
zoxide init fish | source

direnv hook fish | source

