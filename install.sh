#!/bin/bash

# This script was made by https://github.com/yehorych13

# Set colors for messages
RESET="$(tput sgr0)"
ERROR="$(tput setaf 196)"
SUCCESS="$(tput setaf 46)"
INFO="$(tput setaf 39)"
WARNING="$(tput setaf 226)"

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "${ERROR}This script should not be executed as root!${RESET}"
    exit 1
fi

clear

# Variables
PARENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$PARENT_DIR"

BASE_CONFIG_DIR="$HOME/.config"
SCRIPTS_DIR="$PARENT_DIR/scripts"
CONFIG_DIR="$PARENT_DIR/configs"
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
            echo "${ERROR}Failed to make '$script_path' executable!${RESET}"
        fi
    else
        echo "${ERROR}Script '$script' not found in '$SCRIPTS_DIR'${RESET}"
    fi
}

# --- Main script ---
for CONF in "$CONFIG_DIR"/*; do
    CONF_NAME="$(basename "$CONF")"

    if [ -e "$BASE_CONFIG_DIR/$CONF_NAME" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "${INFO}Config for $CONF_NAME found! Trying to backup...${RESET}"

        if mv "$BASE_CONFIG_DIR/$CONF_NAME" "$BACKUP_DIR/" >/dev/null 2>&1; then
            echo "${SUCCESS}Config for $CONF_NAME backed up to $BACKUP_DIR${RESET}"
        else
            echo "${ERROR}Failed to back up $CONF_NAME${RESET}"
        fi
    fi
done

# Back up ZSH config
for file in "$HOME"/.zsh*; do
    if [ -f "$file" ]; then
        echo "${INFO}Found $file file! Trying to backup...${RESET}"
        if mv "$file" "$BACKUP_DIR/" >/dev/null 2>&1; then
            echo "${SUCCESS}$file file backed up to $BACKUP_DIR${RESET}"
        else
            echo "${ERROR}Failed to back up $file${RESET}"
        fi
    fi
done

# --- CREATING SYMLINKS ---
for CONF in "$CONFIG_DIR"/*; do
    CONF_NAME="$(basename "$CONF")"
    TARGET="$BASE_CONFIG_DIR/$CONF_NAME"

    if [ "$CONF_NAME" == "zsh" ]; then
        if ln -snf "$CONFIG_DIR/$CONF_NAME/.zshenv" "$HOME/.zshenv" >/dev/null 2>&1; then
            echo "${SUCCESS}Symlink for .zshenv created!${RESET}"
        else
            echo "${ERROR}Failed to create symlink for .zshenv${RESET}"
        fi
    fi

    if ln -snf "$CONF" "$TARGET" >/dev/null 2>&1; then
        echo "${SUCCESS}Symlink for $CONF_NAME created!${RESET}"
    else
        echo "${ERROR}Failed to create symlink for $CONF_NAME${RESET}"
    fi
done

# Handle existing wallpapers directory by cloning the repository
handle_existing_wallpapers_dir() {
    if [ -d "$DEST_WALLPAPERS_DIR" ]; then
        echo "${WARNING}$DEST_WALLPAPERS_DIR already exists. Merging with the repository...${RESET}"

        # Create a backup of the existing wallpapers before removing
        mv "$DEST_WALLPAPERS_DIR" "$BACKUP_DIR/wallpapers"
        echo "${SUCCESS}Existing wallpapers have been moved to $BACKUP_DIR/wallpapers${RESET}"
    fi

    echo "${INFO}Cloning wallpapers repository into $DEST_WALLPAPERS_DIR...${RESET}"
    git clone --depth 1 https://github.com/yehorych13/wallpapers "$DEST_WALLPAPERS_DIR"

    # Check if there is a backup of the wallpapers
    BACKUP_WALLPAPER_DIR="$BACKUP_DIR/wallpapers"

    if [ -d "$BACKUP_WALLPAPER_DIR" ]; then
        echo "${INFO}Merging existing wallpapers with the cloned repository...${RESET}"

        # Merge the contents of the backup wallpapers into the cloned repository
        cp -r "$BACKUP_WALLPAPER_DIR/"* "$DEST_WALLPAPERS_DIR" 2>/dev/null
        echo "${SUCCESS}Old wallpapers merged with the repository.${RESET}"

        # Remove the backup folder after merging
        rm -rf "$BACKUP_WALLPAPER_DIR"
        echo "${SUCCESS}Backup directory cleaned up.${RESET}"
    fi

    # Remove .git directory to prevent conflicts
    rm -rf "$DEST_WALLPAPERS_DIR/.git"
    echo "${INFO}.git directory removed to avoid conflicts.${RESET}"

    echo "${SUCCESS}Wallpapers successfully cloned and merged.${RESET}"
}

handle_existing_wallpapers_dir

# Handle existing themes directory
handle_existing_dir() {
    local src_dir="$1"
    local dest_dir="$2"
    local name="$3"

    if [ -L "$dest_dir" ]; then
        rm "$dest_dir"
        echo "${SUCCESS}Existing symlink for $name at $dest_dir has been removed.${RESET}"
    elif [ -d "$dest_dir" ]; then
        echo "${WARNING}$name directory already exists at $dest_dir.${RESET}"
        read -p "${INFO}Do you want to move its contents to $src_dir before replacing it? (Y/n): " choice
        choice="${choice:-Y}"  # Default to 'Y' if user presses Enter

        case "$choice" in
            y|Y)
                mkdir -p "$src_dir"
                mv -n "$dest_dir"/* "$src_dir/" 2>/dev/null
                echo "${SUCCESS}Contents of $dest_dir have been moved to $src_dir (existing files were skipped).${RESET}"
                ;;
            *)
                mkdir -p "$BACKUP_DIR"
                mv "$dest_dir" "$BACKUP_DIR/"
                echo "${SUCCESS}$name directory has been moved to $BACKUP_DIR.${RESET}"
                ;;
        esac
    fi
}

handle_existing_dir "$THEMES_DIR" "$DEST_THEMES_DIR" "Themes"

# Detele directory if it exists
[ -d "$DEST_THEMES_DIR" ] && rm -rf "$DEST_THEMES_DIR"

# Create symlinks
ln -s "$THEMES_DIR" "$DEST_THEMES_DIR" && echo "${SUCCESS}Themes have been symlinked to $DEST_THEMES_DIR!${RESET}" || echo "${ERROR}Failed to create symlink for themes!${RESET}"

