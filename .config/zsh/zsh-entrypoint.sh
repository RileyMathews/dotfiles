ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
TPM_PATH="${HOME}/.tmux/plugins/tpm"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

if [ ! -d "$TPM_PATH" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
fi

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

autoload -Uz compinit
compinit -C


zinit cdreplay -q

bindkey -v
bindkey '^y' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
# Disable terminal flow control so Ctrl+S can be used as a zsh keybinding.
stty -ixon 2>/dev/null || true

# Ctrl+S to pick a directory and switch tmux sessions
bindkey -s '^s' 'find-code\n'

# Change cursor shape for different vi modes (non-blinking).
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[2 q';;  # steady block
        viins|main) echo -ne '\e[6 q';; # steady beam
    esac
}
zle -N zle-keymap-select

# Set initial cursor to steady beam for vi insert mode.
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap
    echo -ne "\e[6 q" # steady beam
}
zle -N zle-line-init

# Use steady beam shape cursor on startup.
echo -ne '\e[6 q'

# Use steady beam shape cursor for each new prompt.
# Consider using precmd_functions for this as it's generally preferred
# over preexec for prompt-related actions.
precmd() { echo -ne '\e[6 q' ;}


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


#####################################
# Environment Variables             #
#####################################
export EDITOR="nvim"
export BROWSER="xdg-fork"
export FORGEJO_URL="https://git.rileymathews.com"
export KEYTIMEOUT=1
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share:/usr/local/share:/var/lib/flatpak/exports/share:/home/riley/.local/share/flatpak/exports/share"

export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$HOME/.local/scripts:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.bun/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$HOME/.local/python-scripts:$HOME/.screenlayout"

source "$HOME/.config/zsh/sops-secrets.zsh"

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

alias fh='cd ~ && cd $(find * -type d -maxdepth 2 | fzf)'

alias gst='git status'
alias gaa='git add .'
alias gcmsg='git commit -m'
alias gp='git push'
alias gpsup='git push --set-upstream origin $(git branch --show-current)'
alias gl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout $(git_main_branch)'

alias l='ls -lah --color'

alias k='kubectl'
alias ka='kubectl apply -f'
alias kar='kubectl apply --recursive -f'

alias n='nvim'

alias upd='update-arch'

alias ap='ansible-playbook'

alias s7='system76-power'

alias tss='sudo tailscale switch'

alias ghd="gh-dash"

alias oc='OPENCODE_CONFIG="$HOME/.config/opencode/local-config.json" opencode'
alias ocp='opencode --agent plan'
alias och='opencode --agent haskell-dev --prompt "This project has some compile errors. Please help me fix them."'

alias ndr='nix-direnv-reload'

######################################
# Language Managers                  #
######################################
export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/share/pnpm/bin"

[ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env" # ghcup-env
export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$PATH"

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# export NVM_DIR="$HOME/.nvm"
# [ -f "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -f "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Activate `fnm`: https://github.com/Schniz/fnm
if command -v fnm >/dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

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

[ -f "/home/rileymathews/.ghcup/env" ] && . "/home/rileymathews/.ghcup/env" # ghcup-env
######################################
# Shell utilities                    #
######################################
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
eval "$(wt config shell init zsh)"
eval "$(tv init zsh)"
typeset -U path
path=("$HOME/.local/share/mise/shims" $path)

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

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

######################################
# Local overrides                    #
######################################
for f in "$HOME/.local/shell"/*(N); do
  [[ -r "$f" && -f "$f" ]] && source "$f"
done



# if [[ "$TERM" == "linux" ]]; then
#     export STARSHIP_CONFIG="$HOME/.config/starship/starship-tty.toml"
# else
#     export STARSHIP_CONFIG="$HOME/.config/starship/starship-graphical.toml"
# fi
#
# eval "$(starship init zsh)"

# hyprlog() {
#     echo "copying the last hyprland log to home dir as hyprland.log"
#     cp /run/user/1000/hypr/$(command ls -t /run/user/1000/hypr/ | head -n 1)/hyprland.log ~/hyprland.log
# }
#
# if [[ "$TERM" == "linux" ]] && [[ -z "$DISPLAY" ]] && [[ "$(tty)" == "/dev/tty1" ]]; then
#     start-hyprland
# fi
