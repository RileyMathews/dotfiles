#! /usr/bin/env bash

set -euo pipefail

HOST=$(hostname)

stow -t $HOME common
stow -t $HOME $HOST

