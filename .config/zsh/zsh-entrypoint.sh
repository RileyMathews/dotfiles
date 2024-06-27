ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# docs claim this needs to be loaded before the actual plugin
source $HOME/.config/zsh/zsh-syntax-highligting-theme.sh

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

autoload -U compinit && compinit
zinit cdreplay -q

bindkey '^y' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

eval "$(fzf --zsh)"

HISTSIZE=5000
HISTFILE=~/.cache/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

export EDITOR="nvim"
# .local/secret-bin is for binaries that I do not want to share via dotfiles repo
export PATH="$HOME/.local/bin:$HOME/.local/secret-bin:$HOME/.screenlayout:$PATH"
export KEYTIMEOUT=1

[ -f "$HOME/.config/zsh/.zshrc.secret" ] && source "$HOME/.config/zsh/.zshrc.secret"

#####################################
# Aliases                           #
#####################################
alias mpr="python manage.py runserver"
alias mpmm="python manage.py makemigrations"
alias mpm="python manage.py migrate"
alias mp="python manage.py"
alias zso="source ~/.zshrc"
alias psh='source "$(poetry env info --path)"/bin/activate'

alias be='bundle exec'
alias ber='bundle exec rails'
alias bers='bundle exec rails s'

alias dcb='docker compose build'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dclf='docker compose logs -f'

alias fd='cd $(find * -type d | fzf)'
alias fh='cd ~ && cd $(find * -type d -maxdepth 2 | fzf)'

alias gst='git status'
alias gaa='git add .'
alias gcmsg='git commit -m'
alias gp='git push'
alias gpsup='git push --set-upstream origin $(git branch --show-current)'
alias gl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout main'

alias l='ls -la --color'
alias ls='ls --color'

######################################
# Language Managers                  #
######################################
export PATH="$PATH:$HOME/.cargo/bin"

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

export NVM_DIR="$HOME/.nvm"
[ -f "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -f "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Try to find pyenv, if it's not on the path
export PYENV_ROOT="${PYENV_ROOT:=${HOME}/.pyenv}"
if ! type pyenv > /dev/null && [ -f "${PYENV_ROOT}/bin/pyenv" ]; then
    export PATH="${PYENV_ROOT}/bin:${PATH}"
fi

# Lazy load pyenv
if type pyenv > /dev/null; then
    export PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}"
    function pyenv() {
        unset -f pyenv
        eval "$(command pyenv init -)"
        if [[ -n "${ZSH_PYENV_LAZY_VIRTUALENV}" ]]; then
            eval "$(command pyenv virtualenv-init -)"
        fi
        pyenv $@
    }
fi

[ -f "$HOME/.rbenv/bin/rbenv" ] && eval "$(~/.rbenv/bin/rbenv init - zsh)"

[ -f "/home/rileymathews/.ghcup/env" ] && . "/home/rileymathews/.ghcup/env" # ghcup-env
######################################
# Shell utilities                    #
######################################
eval "$(direnv hook zsh)"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

eval "$(zoxide init --cmd cd zsh)"

######################################
# Functions                          #
######################################
gacp() {
    git add .
    git status
    echo -n "continue? (y/n): "
    read response
    if [ "$response" = "y" ]
    then
        echo -n "Enter commit message: "
        read message
        git commit -m "$(git symbolic-ref --short HEAD) -- $message"
        git push
    else
        git restore --staged .
    fi
}

tsg() {
    directory=$(ls ~/code | fzf)
    _tmux_switch_or_activate ~/code/$directory $directory
}

dote() {
    _tmux_switch_or_activate ~/dotfiles "dotfiles"
}

_tmux_switch_or_activate() {
    directory=$1
    session_name=$2
    if [ -n "$TMUX" ]; then
        command="switch"
    else
        command="attach"
    fi

    if tmux has-session -t $session_name 2>/dev/null; then
    else
        tmux new-session -d -s $session_name -c $directory
    fi
    tmux $command -t $session_name
}

eval "$(starship init zsh)"

if [ -n "$DISPLAY" ] && [ -z "$TMUX" ]; then
    # Attach to the last active session, or create a new one if none exists
    tmux attach-session || tmux new-session
fi
