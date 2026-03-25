export GITHUB_TOKEN=$(cat ${XDG_RUNTIME_DIR}/agenix/github-token-file)
export FORGEJO_TOKEN=$(cat ${XDG_RUNTIME_DIR}/agenix/forgejo-token-file)
# forgejo access token specifically for mcp server
export FORGEJO_ACCESS_TOKEN=$(cat ${XDG_RUNTIME_DIR}/agenix/forgejo-token-file)
export PERSONAL_OPENAI_TOKEN=$(cat ${XDG_RUNTIME_DIR}/agenix/openai-personal-api-token-file)
export BROWSER=librewolf;
export GH_BROWSER=librewolf;
export ALT_BROWSER=google-chrome-stable;
export GH_ALT_BROWSER=google-chrome-stable;
source ~/.config/zsh/zsh-entrypoint.sh
