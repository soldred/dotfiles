#!/bin/bash

THEME="$1"

# List of required files
REQUIRED_FILES=(
    "~/.config/kitty/themes/$THEME.conf"
    "~/.themes/$THEME/gtk-3.0"
    "~/.themes/$THEME/gtk-4.0"
    "~/.config/hyprpanel/themes/$THEME.json"
    "~/.config/hypr/themes/$THEME.conf"
    "~/.config/rofi/themes/$THEME.rasi"
)

# Check if all required files exist
for file in "${REQUIRED_FILES[@]}"; do
    eval file="$file"  # Expand tilde (~) in paths
    if [ ! -e "$file" ]; then
        echo "Error: Required file '$file' not found!"
        notify-send -u critical "Error" "Can't apply '$THEME' theme.\n'$file' not found!"
        exit 1
    fi
done

echo "All required files exist. Proceeding..."

# Set theme
echo "Setting theme to: $THEME"

### HYPRPANEL ###
if command -v hyprpanel &> /dev/null; then
    hyprpanel useTheme ~/.config/hyprpanel/themes/"$THEME".json
    echo "Hyprpanel theme applied."
fi

### GTK THEME ###
if command -v gsettings &> /dev/null; then
    ln -sfn ~/.themes/"$THEME"/gtk-3.0 ~/.config/gtk-3.0
    ln -sfn ~/.themes/"$THEME"/gtk-4.0 ~/.config/gtk-4.0
    gsettings set org.gnome.desktop.interface gtk-theme "$THEME"
    echo "GTK theme set."
fi

### QT THEME
if command -v kvantummanager &> /dev/null; then
    kvantummanager --set "$THEME"
    echo "QT theme set."
fi

### ICON THEME ###
# if command -v gsettings &> /dev/null; then
#     # Check if the icon theme exists in ./icons
#     if [ -d "$HOME/.icons/$THEME" ]; then
#         # Apply the custom icon theme from ./icons/$THEME
#         gsettings set org.gnome.desktop.interface icon-theme "$THEME"
#         echo "Icon theme set to '$THEME'."
#     else
#         # Set the default "Adwaita" icon theme
#         gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
#         echo "Icon theme set to 'Adwaita' (default)."
#         echo "~/.icons/$THEME was not found"
#     fi
# fi

### HYPRLAND & ROFI ###
ln -sf ~/.config/hypr/themes/"$THEME".conf ~/.config/hypr/theme
ln -sf ~/.config/rofi/themes/"$THEME".rasi ~/.config/rofi/theme
echo "Hyprland & Rofi theme linked."

### KITTY ###
ln -sf ~/.config/kitty/themes/"$THEME".conf ~/.config/kitty/theme
kitty_pids=$(pidof kitty)

# Check if there are any running Kitty processes
if [ -z "$kitty_pids" ]; then
    echo "No Kitty processes found."
    exit 1
fi

# Send SIGUSR1 signal to each running Kitty process
for pid in $kitty_pids; do
    kill -SIGUSR1 $pid
    echo "Sent SIGUSR1 to process with PID: $pid"
done

echo "Kitty theme applied."
