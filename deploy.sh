#! /usr/bin/env bash

set -euo pipefail

HOST=$(hostname)
STOW_ARGS=("$@")

PACKAGES=(common)

if [[ -d "$HOST" ]]; then
  PACKAGES+=("$HOST")
fi

stow "${STOW_ARGS[@]}" --target="$HOME" "${PACKAGES[@]}"
