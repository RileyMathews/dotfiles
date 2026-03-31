set -U fish_greeting ""

alias gst 'git status'
alias gaa 'git add .'
alias gcmsg 'git commit -m'
alias gp 'git push'
alias gpsup 'git push --set-upstream origin $(git branch --show-current)'
alias gl 'git pull'
alias gco 'git checkout'
alias gcm 'git checkout $(git_main_branch)'
alias l 'ls -al'
alias tss 'sudo tailscale switch'
alias oc 'opencode'

alias mpr 'python manage.py runserver'
alias mpmm 'python manage.py makemigrations'
alias mpm 'python manage.py migrate'
alias mp 'python manage.py'
alias vim '/run/current-system/sw/bin/nvim'

set -l agenix_dir "$XDG_RUNTIME_DIR/agenix"

if test -r "$agenix_dir/github-token-file"
  set -gx GITHUB_TOKEN (string trim (cat "$agenix_dir/github-token-file"))
end

if test -r "$agenix_dir/forgejo-token-file"
  set -gx FORGEJO_TOKEN (string trim (cat "$agenix_dir/forgejo-token-file"))
  set -gx FORGEJO_ACCESS_TOKEN $FORGEJO_TOKEN
end

if test -r "$agenix_dir/openai-personal-api-token-file"
  set -gx PERSONAL_OPENAI_TOKEN (string trim (cat "$agenix_dir/openai-personal-api-token-file"))
end

zoxide init fish | source
direnv hook fish | source
wt config shell init fish | source
tv init fish | source
starship init fish | source
fzf --fish | source
mise activate fish | source

bind ctrl-y 'accept-autosuggestion'
bind ctrl-s 'findcode; commandline -f repaint'

source ~/.config/fish/local.fish

fish_add_path $HOME/.local/scripts

# Decrypt and source secret env vars
set -l SECRETS_FILE "$HOME/.config/fish/secrets.fish"

if test -f "$SECRETS_FILE"
age --decrypt -i "$HOME/.ssh/id_ed25519" "$SECRETS_FILE" | source
end

set -x EDITOR nvim
