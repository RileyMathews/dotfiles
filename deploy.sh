#! /usr/bin/env bash

set -euo pipefail

HOST=$(hostname)
STOW_ARGS=("$@")
COMMON_DIR=common

COMMON_PACKAGES=(
  shell
  scripts
  tmux
  alacritty
  ghostty
  hyprland
  waybar
  dunst
  rofi
  qutebrowser
  sx
  sxhkd
  picom
  qtile
  librewolf
  opencode
  openpeon
  television
  worktrunk
  nix
  postgres
  shared-ui
  x11
  personal-data
  wireplumber
)

NO_FOLDING_PACKAGES=(
  shell
  scripts
  alacritty
  ghostty
  hyprland
  waybar
  dunst
  rofi
  qutebrowser
  sx
  sxhkd
  picom
  qtile
  librewolf
  opencode
  openpeon
  television
  worktrunk
  nix
  shared-ui
  x11
  personal-data
  wireplumber
)

stow_package() {
  local package=$1
  local -a flags=(--target="$HOME")

  for no_folding_package in "${NO_FOLDING_PACKAGES[@]}"; do
    if [[ "$no_folding_package" == "$package" ]]; then
      flags+=(--no-folding)
      break
    fi
  done

  stow --dir="$COMMON_DIR" "${STOW_ARGS[@]}" "${flags[@]}" "$package"
}

for package in "${COMMON_PACKAGES[@]}"; do
  stow_package "$package"
done

if [[ -d "$HOST" ]]; then
  stow "${STOW_ARGS[@]}" --target="$HOME" "$HOST"
fi
