#!/bin/bash
#
# Dotfiles Installer by github.com/yehorych13
# An intelligent and interactive script to safely set up your configuration files,
# themes, and wallpapers, respecting existing user data.
#

# ---
# SCRIPT SETUP & UI DEFINITIONS
# ---
set -e
if tput setaf 1 &> /dev/null; then
    RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4); BOLD=$(tput bold); RESET=$(tput sgr0)
else
    RED=""; GREEN=""; YELLOW=""; BLUE=""; BOLD=""; RESET=""
fi

# ---
# HELPER FUNCTIONS
# ---
msg() { echo -e "${BLUE}${BOLD}==>${RESET}${BOLD} ${1}${RESET}"; }
warn() { echo -e "${YELLOW}${BOLD}==> WARNING:${RESET} ${1}"; }
error_exit() {
    echo -e "\n${RED}${BOLD}==> ERROR: Prerequisite Check Failed!${RESET}" >&2
    echo -e "${RED}${1}${RESET}" >&2
    echo -e "\nPlease install the missing packages and run the script again." >&2
    exit 1
}
separator() { echo -e "${BLUE}--------------------------------------------------${RESET}"; }

# ---
# PATHS AND VARIABLES
# ---
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIGS_SRC_DIR="$SCRIPT_DIR/configs"
THEMES_SRC_DIR="$SCRIPT_DIR/.themes"
ICONS_SRC_DIR="$SCRIPT_DIR/.icons"

CONFIGS_DEST_DIR="$HOME/.config"
THEMES_DEST_DIR="$HOME/.themes"
ICONS_DEST_DIR="$HOME/.icons"
WALLPAPERS_DEST_DIR="$HOME/Pictures/Wallpapers"

BACKUP_DIR="$HOME/.config_backup_$(date "+%Y-%m-%d_%H-%M-%S")"

# ---
# CORE FUNCTIONS
# ---

# NEW: Function to check for required tools before running anything else
check_prerequisites() {
    separator
    msg "Checking for required tools..."

    local missing_pkg=false
    local instructions=""

    if ! command -v git &> /dev/null; then
        missing_pkg=true
        instructions+="\n- 'git' is not installed. It is required to clone the wallpapers repository."
        instructions+="\n  To install it, run: ${BOLD}sudo pacman -S git${RESET}"
    fi

    if ! command -v dialog &> /dev/null; then
        missing_pkg=true
        instructions+="\n\n- 'dialog' is not installed. It is required for the interactive menus."
        instructions+="\n  To install it, run: ${BOLD}sudo pacman -S dialog${RESET}"
    fi

    if [ "$missing_pkg" = true ]; then
        error_exit "Some required tools are not installed:$instructions"
    fi

    msg "All prerequisites are met. Proceeding..."
}

safe_symlink() {
    local source_path="$1"
    local dest_path="$2"

    if [ -e "$dest_path" ]; then
        if [ -L "$dest_path" ]; then
            rm -f "$dest_path"
        else
            mkdir -p "$BACKUP_DIR"
            warn "Existing item found at '$dest_path'. Backing it up."
            mv "$dest_path" "$BACKUP_DIR/" || error_exit "Failed to back up '$dest_path'."
        fi
    fi

    mkdir -p "$(dirname "$dest_path")"
    ln -snf "$source_path" "$dest_path" || error_exit "Failed to create symlink for '$dest_path'."
}

install_configs() {
    separator
    msg "Installing core configuration files..."

    for config_source in "$CONFIGS_SRC_DIR"/*; do
        local config_name=$(basename "$config_source")
        local config_dest="$CONFIGS_DEST_DIR/$config_name"
        safe_symlink "$config_source" "$config_dest"
    done

    if [ -f "$CONFIGS_SRC_DIR/zsh/.zshenv" ]; then
        safe_symlink "$CONFIGS_SRC_DIR/zsh/.zshenv" "$HOME/.zshenv"
    fi

    echo -e "${GREEN}All configurations symlinked successfully.${RESET}"
}

handle_asset_dir() {
    local src_dir="$1"
    local dest_dir="$2"
    local asset_name="$3"

    separator
    msg "Processing $asset_name..."

    if [ ! -d "$src_dir" ]; then
        warn "'$src_dir' not found. Skipping $asset_name installation."
        return
    fi

    if [ -d "$dest_dir" ] && [ ! -L "$dest_dir" ]; then
        local choice
        choice=$(dialog --clear --title "$asset_name Setup" \
                --menu "An existing '$dest_dir' directory was found. What would you like to do?" 15 70 3 \
                1 "Merge: Keep your existing $asset_name and add mine." \
                2 "Replace: Back up your existing $asset_name and use only mine." \
            3 "Skip: Do not change your current $asset_name." 2>&1 >/dev/tty) || return

        case $choice in
            1)
                msg "Merging your $asset_name with the new ones..."
                local conflict_found=false
                for item in "$dest_dir"/*; do
                    local item_name=$(basename "$item")
                    if [ -e "$src_dir/$item_name" ]; then
                        conflict_found=true
                        mkdir -p "$BACKUP_DIR/${asset_name}_conflicts"
                        warn "Conflict found for '$item_name'. Moving your version to backup."
                        mv "$item" "$BACKUP_DIR/${asset_name}_conflicts/"
                    fi
                done

                cp -rT "$dest_dir" "$src_dir" 2>/dev/null || true
                rm -rf "$dest_dir"
                if $conflict_found; then
                    warn "Some of your $asset_name had name conflicts and were backed up."
                fi
                msg "Merge complete."
                ;;
            2)
                msg "Your old $asset_name will be moved to backup."
                ;;
            3)
                msg "Skipping $asset_name installation."
                return
                ;;
        esac
    fi

    safe_symlink "$src_dir" "$dest_dir"
    echo -e "${GREEN}$asset_name symlinked successfully.${RESET}"
}

install_wallpapers() {
    separator
    local choice
    choice=$(dialog --clear --title "Wallpaper Installation" \
            --menu "How would you like to handle wallpapers?" 15 70 4 \
            1 "Merge: Add my wallpapers to your existing ones." \
            2 "Replace: Use only my wallpapers (yours will be backed up)." \
        3 "Skip: Do not install wallpapers." 2>&1 >/dev/tty) || return

    clear
    case $choice in
        1)
            msg "Merging wallpapers..."
            local temp_wall_dir="/tmp/wallpapers_clone"
            rm -rf "$temp_wall_dir"
            git clone --depth 1 https://github.com/yehorych13/wallpapers "$temp_wall_dir" || error_exit "Failed to clone wallpapers."

            if [ -d "$WALLPAPERS_DEST_DIR" ]; then
                cp -rn "$WALLPAPERS_DEST_DIR"/* "$temp_wall_dir/" 2>/dev/null || true
                rm -rf "$WALLPAPERS_DEST_DIR"
            fi

            mkdir -p "$(dirname "$WALLPAPERS_DEST_DIR")"
            mv "$temp_wall_dir" "$WALLPAPERS_DEST_DIR"
            echo -e "${GREEN}Wallpapers merged successfully.${RESET}"
            ;;
        2)
            msg "Replacing existing wallpapers..."
            if [ -d "$WALLPAPERS_DEST_DIR" ]; then
                mkdir -p "$BACKUP_DIR"
                mv "$WALLPAPERS_DEST_DIR" "$BACKUP_DIR/Wallpapers_old"
                warn "Your existing wallpapers have been moved to backup."
            fi
            git clone --depth 1 https://github.com/yehorych13/wallpapers "$WALLPAPERS_DEST_DIR" || error_exit "Failed to clone wallpapers."
            echo -e "${GREEN}Wallpapers replaced successfully.${RESET}"
            ;;
        3)
            msg "Skipping wallpaper installation."
            return
            ;;
    esac

    if dialog --yesno "Do you want to remove the .git directory from the new wallpapers folder?" 8 70; then
        rm -rf "$WALLPAPERS_DEST_DIR/.git"
        msg ".git directory removed."
    fi
}


# ---
# MAIN EXECUTION
# ---
main() {
    if [[ $EUID -eq 0 ]]; then error_exit "This script should not be executed as root!"; fi

    # Run prerequisite check at the very beginning
    check_prerequisites

    cd "$SCRIPT_DIR"

    local choices
    choices=$(dialog --separate-output --checklist "Select components to set up:" 15 70 3 \
            1 "Core Configs (Hyprland, Kitty, etc.)" on \
            2 "Themes and Icons" on \
        3 "Wallpapers" on 2>&1 >/dev/tty)

    if [ -z "$choices" ]; then error_exit "No components selected. Exiting."; fi

    clear
    separator
    msg "Starting dotfiles setup..."

    for choice in $choices; do
        case $choice in
            1) install_configs ;;
            2)
                handle_asset_dir "$THEMES_SRC_DIR" "$THEMES_DEST_DIR" "Themes"
                handle_asset_dir "$ICONS_SRC_DIR" "$ICONS_DEST_DIR" "Icons"
                ;;
            3) install_wallpapers ;;
        esac
    done

    dialog --title "Setup Complete" --msgbox "All selected components have been set up successfully.\n\nBacked up files (if any) are located in:\n$BACKUP_DIR" 12 70
    clear
    separator
    msg "Dotfiles setup finished!"
}

main
