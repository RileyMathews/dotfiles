source ~/.config/zsh/zsh-entrypoint.sh

# pnpm
export PNPM_HOME="/home/riley/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
