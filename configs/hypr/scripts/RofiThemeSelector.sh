#!/bin/bash

# Directory containing theme directories
THEME_DIR="$HOME/.themes"

# Get a list of available themes
THEMES=$(ls "$THEME_DIR")

# Use rofi to select a theme with case-insensitive search
SELECTED_THEME=$(echo "$THEMES" | rofi -dmenu -p "Select Theme:" -i)

# Check if a theme was selected
if [ -z "$SELECTED_THEME" ]; then
    echo "No theme selected."
    exit 1
fi

# Run the previous script to apply the selected theme
~/.config/hypr/scripts/SelectTheme.sh "$SELECTED_THEME"

