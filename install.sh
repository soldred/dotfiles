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

    if [ -d "$BASE_CONFIG_DIR/$CONF_NAME" ]; then
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
        # Створюємо симлінк для .zshenv
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

# Copy Wallpapers to ~/Pictures/Wallpapers
if [ -d "$WALLPAPERS_DIR" ]; then
    mkdir -p "$DEST_WALLPAPERS_DIR"
    if cp -r "$WALLPAPERS_DIR"/* "$DEST_WALLPAPERS_DIR/"; then
        echo "Wallpapers have been copied to $DEST_WALLPAPERS_DIR!"
    else
        echo "$ERROR Failed to copy wallpapers!"
    fi
else
    echo "$ERROR Wallpapers directory not found!"
fi

# Copy themes to ~/.themes
if [ -d "$THEMES_DIR" ]; then
    mkdir -p "$DEST_THEMES_DIR"
    if cp -r "$THEMES_DIR"/* "$DEST_THEMES_DIR/"; then
        echo "Themes have been copied to $DEST_THEMES_DIR!"
    else
        echo "$ERROR Failed to copy themes!"
    fi
else
    echo "$ERROR Themes directory not found!"
fi

