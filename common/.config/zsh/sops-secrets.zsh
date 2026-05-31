# Cache decrypted SOPS dotenv secrets in the per-user runtime directory.

_zsh_source_secret_env() {
    emulate -L zsh
    setopt allexport
    source "$1"
}

_zsh_source_sops_secrets_direct() {
    emulate -L zsh

    local secrets_file="$1"

    (( $+commands[sops] )) || return 1

    setopt allexport
    source <(SOPS_AGE_SSH_PRIVATE_KEY_FILE="${SOPS_AGE_SSH_PRIVATE_KEY_FILE:-$HOME/.ssh/id_ed25519}" sops --decrypt --input-type dotenv --output-type dotenv "$secrets_file")
}

_zsh_path_private() {
    emulate -L zsh

    local path="$1"
    local -A path_stat

    zmodload zsh/stat || return 1
    zstat -H path_stat "$path" 2>/dev/null || return 1

    (( path_stat[uid] == UID && (path_stat[mode] & 8#077) == 0 ))
}

_zsh_sops_cache_safe() {
    emulate -L zsh

    local cache_file="$1"
    local secrets_file="$2"

    [[ -r "$cache_file" && -f "$cache_file" && ! -L "$cache_file" && -O "$cache_file" && ! "$secrets_file" -nt "$cache_file" ]] && _zsh_path_private "$cache_file"
}

_zsh_write_sops_secret_cache() {
    emulate -L zsh

    local secrets_file="$1"
    local cache_file="$2"
    local tmp_file
    local old_umask
    local result

    (( $+commands[sops] )) || return 1

    old_umask=$(umask)
    umask 077
    tmp_file="$(mktemp "${cache_file}.tmp.XXXXXX")" || {
        umask "$old_umask"
        return 2
    }

    if SOPS_AGE_SSH_PRIVATE_KEY_FILE="${SOPS_AGE_SSH_PRIVATE_KEY_FILE:-$HOME/.ssh/id_ed25519}" sops --decrypt --input-type dotenv --output-type dotenv "$secrets_file" >| "$tmp_file"; then
        chmod 600 "$tmp_file" 2>/dev/null || true
        mv -f "$tmp_file" "$cache_file"
        result=$?
        umask "$old_umask"
        (( result == 0 )) && return 0
        rm -f "$tmp_file"
        return 2
    fi

    result=$?
    rm -f "$tmp_file"
    umask "$old_umask"
    return $result
}

_zsh_load_sops_secrets() {
    emulate -L zsh

    local secrets_file="$HOME/.config/zsh/secrets.env"
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$UID}"
    local cache_file
    local result

    [[ -r "$secrets_file" ]] || return 0

    if [[ -z "$runtime_dir" || ! -d "$runtime_dir" || -L "$runtime_dir" || ! -O "$runtime_dir" || ! -w "$runtime_dir" ]] || ! _zsh_path_private "$runtime_dir"; then
        _zsh_source_sops_secrets_direct "$secrets_file"
        return
    fi

    cache_file="$runtime_dir/zsh-secrets.env"

    if _zsh_sops_cache_safe "$cache_file" "$secrets_file"; then
        _zsh_source_secret_env "$cache_file"
        return
    fi

    _zsh_write_sops_secret_cache "$secrets_file" "$cache_file"
    result=$?

    if (( result == 0 )) && _zsh_sops_cache_safe "$cache_file" "$secrets_file"; then
        _zsh_source_secret_env "$cache_file"
        return
    fi

    # If cache creation failed for filesystem reasons, keep the old direct path working.
    (( result == 2 )) && _zsh_source_sops_secrets_direct "$secrets_file"
}

_zsh_load_sops_secrets
unfunction _zsh_load_sops_secrets _zsh_write_sops_secret_cache _zsh_sops_cache_safe _zsh_path_private _zsh_source_sops_secrets_direct _zsh_source_secret_env 2>/dev/null
