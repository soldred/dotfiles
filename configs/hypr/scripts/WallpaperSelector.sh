#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if [ ! -d "$WALLPAPER_DIR" ]; then
  rofi -e "No such directory: $WALLPAPER_DIR"
  exit 1
fi

generate_rofi_list() {
  find "$WALLPAPER_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) |
    while read -r file; do
      echo -e "$(basename "$file")\0icon\x1fthumbnail://$file"
    done
}

SELECTED_BASENAME=$(generate_rofi_list | rofi -dmenu -i -p "" -show-icons -theme ~/.config/rofi/wallpaper-selector.rasi)

if [ -z "$SELECTED_BASENAME" ]; then
  exit 1
fi

FULL_PATH="$WALLPAPER_DIR/$SELECTED_BASENAME"

ln -sf "$FULL_PATH" ~/.cache/current_wallpaper

if ! pgrep -x "swww-daemon" >/dev/null; then
  swww-daemon &
  sleep 0.5
fi

# Типи переходів: simple, any, outer, random, wipe, wave, grow, center, step
swww img "$FULL_PATH" \
  --transition-type any \
  --transition-duration 2.5 \
  --transition-fps 60
wal -i "$FULL_PATH" --cols16 darken >/dev/null 2>&1

killall waybar
waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css >/dev/null 2>&1 &

~/.config/hypr/scripts/GenerateSwayncTheme.sh
