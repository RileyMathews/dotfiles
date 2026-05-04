set -g fish_greeting ""

set -l os (uname)

set -l clean_path
for path in $PATH
  if test -d "$path"
    set -a clean_path "$path"
  end
end
set -gx PATH $clean_path
set -e __MISE_ORIG_PATH
set -e RBENV_ORIG_PATH

switch $os
case Linux
  set -gx ANDROID_HOME "$HOME/Android/Sdk"

  fish_add_path --path \
    "$HOME/.local/scripts" \
    "$HOME/.cargo/bin" \
    "$HOME/.local/bin" \
    "$HOME/.bun/bin" \
    "$ANDROID_HOME/emulator" \
    "$ANDROID_HOME/platform-tools" \
    "$ANDROID_HOME/cmdline-tools/latest/bin"
case Darwin
  fish_add_path --path \
    "$HOME/.local/scripts" \
    "$HOME/.local/bin"
end

alias gst 'git status'
alias gaa 'git add .'
alias gcmsg 'git commit -m'
alias gp 'git push'
alias gpsup 'git push --set-upstream origin $(git branch --show-current)'
alias gl 'git pull'
alias gco 'git checkout'
alias gcb 'git checkout -b'
alias gcm 'git checkout (git_main_branch)'
alias l 'ls -al'
alias tss 'sudo tailscale switch'
alias oc 'opencode'

alias zig 'anyzig'

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

command -q zoxide; and zoxide init fish | source
command -q direnv; and direnv hook fish | source
command -q wt; and wt config shell init fish | source
command -q tv; and tv init fish | source
command -q starship; and starship init fish | source
command -q fzf; and fzf --fish | source
command -q mise; and mise activate fish | source
command -q fnm; and fnm env --use-on-cd --shell fish | source
command -q rbenv; and rbenv init - --no-rehash fish | source

bind ctrl-y 'accept-autosuggestion'
bind ctrl-s 'sesh-session-switch; commandline -f repaint'

# Decrypt and source secret env vars
set -l SECRETS_FILE "$HOME/.config/fish/secrets.fish"

if test -f "$SECRETS_FILE"
age --decrypt -i "$HOME/.ssh/id_ed25519" "$SECRETS_FILE" | source
end

set -x EDITOR nvim
set -x BROWSER xdg-fork
set -x FORGEJO_URL "https://git.rileymathews.com"
