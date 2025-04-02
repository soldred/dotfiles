#!/bin/bash

# This script was made by https://github.com/yehorych13

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root!"
    exit 1
fi

clear

# Variables
ERROR="$(tput setaf 196)[ERROR]${RESET}"

PARENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$PARENT_DIR"

BASE_CONFIG_DIR="$HOME/.config"
SCRIPTS_DIR="$PARENT_DIR/scripts"
CONFIG_DIR="$PARENT_DIR/configs"
WALLPAPERS_DIR="$PARENT_DIR/Wallpapers"
DEST_WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
THEMES_DIR="$PARENT_DIR/.themes"
DEST_THEMES_DIR="$HOME/.themes"

# Determine backup dir variable
BACKUP_DIR="$HOME/.config/backup_$(date "+%Y-%m-%d_%H-%M-%S")"

execute_script() {
    local script="$1"
    local script_path="$SCRIPTS_DIR/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            "$script_path"
        else
            echo "$ERROR Failed to make '$script_path' executable!"
        fi
    else
        echo "$ERROR Script '$script' not found in '$SCRIPTS_DIR'"
    fi
}

# --- Main script ---
for CONF in "$CONFIG_DIR"/*; do
    CONF_NAME="$(basename "$CONF")"

    if [ -e "$BASE_CONFIG_DIR/$CONF_NAME" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "Config for $CONF_NAME found! Trying to backup..."

        if mv "$BASE_CONFIG_DIR/$CONF_NAME" "$BACKUP_DIR/" >/dev/null 2>&1; then
            echo "Config for $CONF_NAME backed up to $BACKUP_DIR"
        else
            echo "$ERROR Failed to back up $CONF_NAME"
        fi
    fi
done

# Back up ZSH config
for file in "$HOME"/.zsh*; do
    if [ -f "$file" ]; then
        echo "Found $file file! Trying to backup..."
        if mv "$file" "$BACKUP_DIR/" >/dev/null 2>&1; then
            echo "$file file backed up to $BACKUP_DIR"
        else
            echo "$ERROR Failed to back up $file"
        fi
    fi
done

# --- CREATING SYMLINKS ---
for CONF in "$CONFIG_DIR"/*; do
    CONF_NAME="$(basename "$CONF")"
    TARGET="$BASE_CONFIG_DIR/$CONF_NAME"

    if [ "$CONF_NAME" == "zsh" ]; then
        if ln -snf "$CONFIG_DIR/$CONF_NAME/.zshenv" "$HOME/.zshenv" >/dev/null 2>&1; then
            echo "Symlink for .zshenv created!"
        else
            echo "$ERROR Failed to create symlink for .zshenv"
        fi
    fi

    if ln -snf "$CONF" "$TARGET" >/dev/null 2>&1; then
        echo "Symlink for $CONF_NAME created!"
    else
        echo "$ERROR Failed to create symlink for $CONF_NAME"
    fi
done

# NOTE: This function moves the contents of ~/Pictures/Wallpapers and .themes into the $PARENT_DIR folder to later create symlinks.
#       Why is this needed?
#       The goal is to keep all configuration files in one place ($PARENT_DIR) and then create symlinks to the right locations.
#       If you already have wallpapers and themes, they will be moved to $PARENT_DIR, and symlinks will be created.
#       This way, nothing will change for the end user.
#       If you don't want to move your wallpapers and themes, you can back them up to $BACKUP_DIR instead.
#       Press 'y' or 'ENTER' to move your content to the dotfiles folder.
#       Press any other key to back up your content.

handle_existing_dir() {
    local src_dir="$1"
    local dest_dir="$2"
    local name="$3"

    if [ -L "$dest_dir" ]; then
        rm "$dest_dir"
        echo "Existing symlink for $name at $dest_dir has been removed."
    elif [ -d "$dest_dir" ]; then
        echo "$name directory already exists at $dest_dir."
        read -p "Do you want to move its contents to $src_dir before replacing it? (Y/n): " choice
        choice="${choice:-Y}"  # Default to 'Y' if user presses Enter

        case "$choice" in
            y|Y)
                mkdir -p "$src_dir"
                mv -n "$dest_dir"/* "$src_dir/" 2>/dev/null
                echo "Contents of $dest_dir have been moved to $src_dir (existing files were skipped)."
                ;;
            *)
                mkdir -p "$BACKUP_DIR"
                mv "$dest_dir" "$BACKUP_DIR/"
                echo "$name directory has been moved to $BACKUP_DIR."
                ;;
        esac
    fi
}

handle_existing_dir "$WALLPAPERS_DIR" "$DEST_WALLPAPERS_DIR" "Wallpapers"
handle_existing_dir "$THEMES_DIR" "$DEST_THEMES_DIR" "Themes"

# Detele directory if it exists
[ -d "$DEST_WALLPAPERS_DIR" ] && rm -rf "$DEST_WALLPAPERS_DIR"
[ -d "$DEST_THEMES_DIR" ] && rm -rf "$DEST_THEMES_DIR"

# Create symlinks
ln -s "$WALLPAPERS_DIR" "$DEST_WALLPAPERS_DIR" && echo "Wallpapers have been symlinked to $DEST_WALLPAPERS_DIR!" || echo "$ERROR Failed to create symlink for wallpapers!"
ln -s "$THEMES_DIR" "$DEST_THEMES_DIR" && echo "Themes have been symlinked to $DEST_THEMES_DIR!" || echo "$ERROR Failed to create symlink for themes!"

