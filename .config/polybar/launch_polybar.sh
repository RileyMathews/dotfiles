#! /bin/sh
killall polybar
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload toph &> ~/.local/share/polybar/polybar.log &
  done
else
  polybar --reload toph &
fi
