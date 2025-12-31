#!/bin/bash

# Directory containing animations
ANIMATIONS_DIR="$HOME/.config/hypr/animations"

ANIMATIONS=$(ls "$ANIMATIONS_DIR" | sed 's/\.conf$//')

# Use rofi to select an animation
SELECTED_ANIMATION=$(echo "$ANIMATIONS" | rofi -dmenu -p "Select animation" -i)

# Check if an animation was selected
if [ -z "$SELECTED_ANIMATION" ]; then
    echo "No animation selected."
    exit 1
fi

ln -snf "$ANIMATIONS_DIR/$SELECTED_ANIMATION.conf" ~/.config/hypr/configs/animations.conf
