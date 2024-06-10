#!/bin/bash

# Check if dunst is already running
if pgrep -x "dunst" > /dev/null
then
  # If dunst is running, kill the existing process
  pkill dunst
fi

# Start a new instance of dunst
dunst -config <(envsubst < ~/.config/dunst/dunstrc) &
