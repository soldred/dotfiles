#!/bin/bash

STATE_FILE="/tmp/gamemode.lock"

if [ -f "$STATE_FILE" ]; then

    hyprctl reload

    if ! pgrep -x "hypridle" > /dev/null; then
        hypridle &
    fi

    rm "$STATE_FILE"

    notify-send -u normal "Game Mode Deactivated" "System settings restored"
else

    hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:drop_shadow 0;\
        keyword decoration:blur:enabled 0;\
        keyword decoration:active_opacity 1;\
        keyword decoration:inactive_opacity 1;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 0;\
        keyword decoration:rounding 0"

    pkill hypridle

    touch "$STATE_FILE"

    notify-send -u normal "Game Mode Activated" "All distractions disabled"
fi
