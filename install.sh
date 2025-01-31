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
DEST_WALLPAPERS_DIR="$HOME/Pictures/"

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

if [ -f "$HOME/.zshrc" ]; then
    # Create backup dir if it's needed
    mkdir -p "$BACKUP_DIR"
    echo "Found .zshrc file! Trying to backup..."
    if mv "$HOME/.zshrc" "$BACKUP_DIR/" >/dev/null 2>&1; then
        echo ".zshrc file backed up to $BACKUP_DIR"
    else
        echo "$ERROR Failed to back up .zshrc"
    fi
fi

# --- CREATING SYMLINKS ---
for CONF in "$CONFIG_DIR"/*; do
    CONF_NAME="$(basename "$CONF")"
    if [ "$CONF_NAME" == "zsh" ]; then
        if ln -snf "$CONFIG_DIR/$CONF_NAME/.zshrc" "$HOME/.zshrc" >/dev/null 2>&1; then
            echo "Symlink for .zshrc created!"
        else
            echo "$ERROR Failed to create symlink for .zshrc"
        fi
    else
        if ln -snf "$CONFIG_DIR/$CONF_NAME" "$BASE_CONFIG_DIR/$CONF_NAME" >/dev/null 2>&1; then
            echo "Symlink for $CONF_NAME created!"
        else
            echo "$ERROR Failed to create symlink for $CONF_NAME"
        fi
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

