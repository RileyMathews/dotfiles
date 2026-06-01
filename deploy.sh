#!/usr/bin/env bash

set -euo pipefail

stow "$@" --target="$HOME" .
