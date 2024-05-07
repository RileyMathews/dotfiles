# Catppuccin Mocha Theme (for zsh-syntax-highlighting)
#
# Paste this files contents inside your ~/.zshrc before you activate zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES

ROSEWATER="#f5e0dc"
FLAMINGO="#f2cdcd"
PINK="#f5c2e7"
MAUVE="#cba6f7"
RED="#f38ba8"
MAROON="#eba0ac"
PEACH="#fab387"
YELLOW="#f9e2af"
GREEN="#a6e3a1"
TEAL="#94e2d5"
SKY="#89dceb"
SAPPHIRE="#74c7ec"
BLUE="#89b4fa"
LAVENDER="#b4befe"
TEXT="#cdd6f4"
SUBTEXT1="#bac2de"
SUBTEXT0="#a6adc8"
OVERLAY2="#9399b2"
OVERLAY1="#7f849c"
OVERLAY0="#6c7086"
SURFACE2="#585b70"
SURFACE1="#45475a"
SURFACE0="#313244"
BASE="#1e1e2e"
MANTLE="#181825"
CRUST="#11111b"


# Main highlighter styling: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
#
## General
### Diffs
### Markup
## Classes
## Comments
ZSH_HIGHLIGHT_STYLES[comment]="fg=$OVERLAY0"
## Constants
## Entitites
## Functions/methods
ZSH_HIGHLIGHT_STYLES[alias]="fg=$BLUE"
ZSH_HIGHLIGHT_STYLES[suffix-alias]="fg=$BLUE"
ZSH_HIGHLIGHT_STYLES[global-alias]="fg=$BLUE"
ZSH_HIGHLIGHT_STYLES[function]="fg=$BLUE"
ZSH_HIGHLIGHT_STYLES[command]="fg=$BLUE"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=$BLUE,italic"
ZSH_HIGHLIGHT_STYLES[autodirectory]="fg=$BLUE,italic"
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=$MAROON"
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=$MAROON"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]="fg=$MAROON"
## Keywords
## Built ins
ZSH_HIGHLIGHT_STYLES[builtin]="fg=$MAUVE"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=$SAPPHIRE"
ZSH_HIGHLIGHT_STYLES[hashed-command]="fg=$BLUE"
## Punctuation
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=$OVERLAY2"
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]="fg=$OVERLAY2"
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]="fg=$OVERLAY2"
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]="fg=$OVERLAY2"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]="fg=$OVERLAY2"
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]="fg=$PINK"
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]="fg=$PINK"
## Serializable / Configuration Languages
## Storage
## Strings
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]="fg=$LAVENDER"
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]="fg=$LAVENDER"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=$GREEN"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]="fg=$RED,underline"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=$GREEN"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]="fg=$RED,underline"
ZSH_HIGHLIGHT_STYLES[rc-quote]="fg=$GREEN"
## Variables
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=$RED"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]="fg=$RED,underline"
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]="fg=$RED"
ZSH_HIGHLIGHT_STYLES[assign]="fg=$TEXT"
ZSH_HIGHLIGHT_STYLES[named-fd]="fg=$TEXT"
ZSH_HIGHLIGHT_STYLES[numeric-fd]="fg=$TEXT"
## No category relevant in spec
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=$RED,underline"
ZSH_HIGHLIGHT_STYLES[path]="fg=$TEXT"
ZSH_HIGHLIGHT_STYLES[path_pathseparator]="fg=$BLUE"
ZSH_HIGHLIGHT_STYLES[path_prefix]="fg=$BLUE"
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]="fg=$BLUE,underline"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=$TEXT"
ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=$MAUVE"
#ZSH_HIGHLIGHT_STYLES[command-substitution]="fg=?"
#ZSH_HIGHLIGHT_STYLES[command-substitution-unquoted]="fg=?"
#ZSH_HIGHLIGHT_STYLES[process-substitution]="fg=?"
#ZSH_HIGHLIGHT_STYLES[arithmetic-expansion]="fg=?"
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]="fg=$RED,underline"
ZSH_HIGHLIGHT_STYLES[redirection]="fg=$TEXT"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=$TEXT"
ZSH_HIGHLIGHT_STYLES[default]="fg=$TEXT"
ZSH_HIGHLIGHT_STYLES[cursor]="fg=$TEXT"

