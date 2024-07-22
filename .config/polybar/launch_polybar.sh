#!/bin/bash

killall polybar

if type "xrandr"; then
  # Check if there's a primary monitor
  primary_monitor=$(xrandr --query | grep " connected primary" | cut -d" " -f1)
  
  if [ -n "$primary_monitor" ]; then
    # If there's a primary monitor, launch the primary bar on it
    MONITOR=$primary_monitor polybar --reload primary &> ~/.local/share/polybar/polybar_primary.log &
    
    # Launch the secondary bar on all other connected monitors
    for m in $(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1); do
      MONITOR=$m polybar --reload secondary &> ~/.local/share/polybar/polybar_secondary_${m}.log &
    done
  else
    # If there's no primary monitor, get the first connected monitor
    first_monitor=$(xrandr --query | grep " connected" | head -n 1 | cut -d" " -f1)
    
    # Launch the primary bar on the first monitor
    MONITOR=$first_monitor polybar --reload primary &> ~/.local/share/polybar/polybar_primary.log &
    
    # Launch the secondary bar on all other connected monitors
    for m in $(xrandr --query | grep " connected" | grep -v "$first_monitor" | cut -d" " -f1); do
      MONITOR=$m polybar --reload secondary &> ~/.local/share/polybar/polybar_secondary_${m}.log &
    done
  fi
else
  # Fallback if xrandr is not available
  polybar --reload primary &
fi
