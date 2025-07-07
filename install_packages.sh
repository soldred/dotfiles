#!/bin/bash
#
# Hyprland Environment Installer for minimal Arch Linux.
# A robust, user-friendly script that handles dependencies, user choices,
# and common edge cases for a flawless setup made by github.com/yehorych13.
#
# ---
# SCRIPT SETUP
# ---
set -e # Exit immediately if a command exits with a non-zero status.

# ---
# COLOR and UI DEFINITIONS
# ---
if tput setaf 1 &> /dev/null; then
    RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4); BOLD=$(tput bold); RESET=$(tput sgr0)
else
    RED=""; GREEN=""; YELLOW=""; BLUE=""; BOLD=""; RESET=""
fi

# ---
# Helper functions for logging
# ---
msg() { echo -e "${BLUE}${BOLD}==>${RESET}${BOLD} ${1}${RESET}"; }
warn() { echo -e "${YELLOW}${BOLD}==> WARNING:${RESET} ${1}"; }
error_exit() { clear; echo -e "\n${RED}${BOLD}==> ERROR:${RESET} ${1}" >&2; exit 1; }
separator() { echo -e "${BLUE}--------------------------------------------------${RESET}"; }

# ---
# GLOBAL VARIABLES
# ---
AUR_HELPER=""
DM_SELECTED=""
RECOMMENDED_GPU="" # To store the auto-detected GPU type
GPU_PACKAGES=()    # To store the final list of driver packages

# ---
# SYSTEM PREPARATION AND PREREQUISITE CHECKS
# ---
prepare_system() {
    separator
    msg "Running System Preparation and Prerequisite Checks..."

    if [ "$EUID" -eq 0 ]; then error_exit "This script must NOT be run as root. Please run as a regular user with sudo privileges."; fi
    if ! command -v sudo &> /dev/null; then error_exit "'sudo' command not found. Please install it first to proceed."; fi
    msg "Checking for internet connectivity..."
    if ! ping -c 1 -W 3 archlinux.org &> /dev/null; then error_exit "No internet connection. Please connect to the internet and try again."; fi
    msg "Internet connection is available."
    if ! lspci | grep -q -i 'vga\|3d'; then
        warn "No GPU detected. This script is intended for systems with graphical capabilities."
        dialog --yesno "Are you sure you want to continue on this (potentially headless) system?" 8 70 || error_exit "Installation cancelled."
    fi
    if [ -z "$TERM" ]; then error_exit "The 'TERM' environment variable is not set. Cannot run 'dialog'."; fi

    local essential_pkgs=("git" "dialog" "base-devel")
    local pkgs_to_install=()
    for pkg in "${essential_pkgs[@]}"; do
        if ! pacman -Q "$pkg" &> /dev/null; then pkgs_to_install+=("$pkg"); fi
    done

    if [ ${#pkgs_to_install[@]} -gt 0 ]; then
        msg "Installing essential tools: ${pkgs_to_install[*]}"
        sudo pacman -S --noconfirm --needed "${pkgs_to_install[@]}"
    fi

    local yay_installed=false; command -v yay &> /dev/null && yay_installed=true
    local paru_installed=false; command -v paru &> /dev/null && paru_installed=true

    if $yay_installed && $paru_installed; then
        local choice; choice=$(dialog --clear --title "AUR Helper" --menu "Which AUR helper would you like to use?" 15 50 2 1 "yay" 2 "paru" 2>&1 >/dev/tty) || error_exit "Selection cancelled."
        [[ "$choice" == "1" ]] && AUR_HELPER="yay" || AUR_HELPER="paru"
    elif $yay_installed; then msg "'yay' is already installed. Using it."; AUR_HELPER="yay"
    elif $paru_installed; then msg "'paru' is already installed. Using it."; AUR_HELPER="paru"
    else
        local choice; choice=$(dialog --clear --title "AUR Helper" --menu "No AUR helper found. Please choose one to install." 15 50 2 1 "yay   (Popular)" 2 "paru  (Fast, Rust-based)" 2>&1 >/dev/tty) || error_exit "Selection cancelled."
        clear
        case $choice in
            1) msg "Installing 'yay'..."; git clone https://aur.archlinux.org/yay.git /tmp/yay && (cd /tmp/yay && makepkg -si --noconfirm) || error_exit "Failed to install yay."; AUR_HELPER="yay" ;;
            2) msg "Installing 'paru'..."; git clone https://aur.archlinux.org/paru.git /tmp/paru && (cd /tmp/paru && makepkg -si --noconfirm) || error_exit "Failed to install paru."; AUR_HELPER="paru" ;;
            *) error_exit "Invalid selection." ;;
        esac
        rm -rf /tmp/yay /tmp/paru
    fi
    msg "Using '$AUR_HELPER' as the AUR helper for this session."
}

# ---
# PACKAGE DEFINITIONS (SEPARATED FOR RELIABILITY)
# ---
repo_packages=(base-devel git curl wget unzip less xdg-user-dirs polkit hyprland hyprlock hypridle xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xorg-xwayland xorg-xhost wl-clipboard polkit-gnome gnome-keyring pipewire pipewire-pulse pipewire-alsa wireplumber sof-firmware gtk3 gtk4 libdbusmenu-gtk3 gtk-engine-murrine sassc qt5-wayland qt6-wayland qt5ct qt6ct kvantum kvantum-qt5 ttf-jetbrains-mono-nerd ttf-ubuntu-nerd ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji nautilus gvfs gvfs-gphoto2 swww kitty neovim ksnip loupe mpv btop rofi-wayland pavucontrol wf-recorder discord)

aur_packages=(ags-hyprpanel-git python-pywal16 matugen better-control-git waypaper gpu-screen-recorder grimshot hyprpicker)
terminal_power_tools=(zsh less ripgrep fd make gcc zoxide eza starship fzf)
dev_tools=(docker docker-compose github-cli)
dm_packages_sddm=(sddm)
dm_packages_gdm=(gdm)
dm_packages_ly=(ly)

# ---
# GPU DRIVER SELECTION LOGIC
# ---
detect_gpu_recommendation() {
    local gpu_info; gpu_info=$(lspci | grep -E "VGA|3D" | head -n 1)
    if echo "$gpu_info" | grep -iq "NVIDIA"; then RECOMMENDED_GPU="nvidia"
    elif echo "$gpu_info" | grep -iq "AMD"; then RECOMMENDED_GPU="amd"
    elif echo "$gpu_info" | grep -iq "Intel"; then RECOMMENDED_GPU="intel"
else RECOMMENDED_GPU="unknown"; fi
}

select_gpu_drivers() {
    # Define package lists for clarity
    local nvidia_proprietary_pkgs=(nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings)
    local nvidia_open_pkgs=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings)
    local amd_pkgs=(mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver libva-utils)
    local intel_pkgs=(mesa lib32-mesa vulkan-intel intel-media-driver)

    detect_gpu_recommendation

    local default_choice="5" # Default to 'None'
    local recommendation_text="Auto-detection could not determine your GPU."

    if [ "$RECOMMENDED_GPU" = "nvidia" ]; then
        default_choice="1"
        recommendation_text="NVIDIA GPU detected (Proprietary Recommended)"
    elif [ "$RECOMMENDED_GPU" = "amd" ]; then
        default_choice="3"
        recommendation_text="AMD GPU detected (Recommended)"
    elif [ "$RECOMMENDED_GPU" = "intel" ]; then
        default_choice="4"
        recommendation_text="Intel Graphics detected (Recommended)"
    fi

    local driver_choice
    driver_choice=$(dialog --clear --title "Graphics Driver Selection" \
            --default-item "$default_choice" \
            --menu "Please select the graphics drivers to install.\n\nRecommendation: $recommendation_text" 20 110 5 \
            1 "NVIDIA (Proprietary): ${nvidia_proprietary_pkgs[*]}" \
            2 "NVIDIA (Open Source): ${nvidia_open_pkgs[*]}" \
            3 "AMD (Open Source Mesa): ${amd_pkgs[*]}" \
            4 "Intel (Open Source Mesa): ${intel_pkgs[*]}" \
        5 "None (I will install drivers manually)" 2>&1 >/dev/tty) || error_exit "Selection cancelled."

    case $driver_choice in
        1) msg "Selected NVIDIA Proprietary drivers."; GPU_PACKAGES=("${nvidia_proprietary_pkgs[@]}") ;;
        2) msg "Selected NVIDIA Open Source drivers."; GPU_PACKAGES=("${nvidia_open_pkgs[@]}") ;;
        3) msg "Selected AMD drivers."; GPU_PACKAGES=("${amd_pkgs[@]}") ;;
        4) msg "Selected Intel drivers."; GPU_PACKAGES=("${intel_pkgs[@]}") ;;
        5) msg "Skipping automatic driver installation."; warn "You must install graphics drivers manually." ;;
        *) error_exit "Invalid driver selection." ;;
    esac
}

# ---
# MAIN EXECUTION
# ---
main() {
    prepare_system
    dialog --title "Welcome" --msgbox "This script will now install the complete Hyprland environment. You will be asked a few questions to customize the installation." 10 70
    select_gpu_drivers

    # --- Build the final package lists ---
    local final_repo_list=("${repo_packages[@]}" "${GPU_PACKAGES[@]}")
    local final_aur_list=("${aur_packages[@]}")
    local dev_tools_selected=false

    local tools_choice; tools_choice=$(dialog --separate-output --checklist "Select optional tools to install:" 15 70 2 \
            1 "Terminal Power-tools (zsh, eza, etc.)" on \
        2 "Developer Tools (Docker, GitHub CLI)" off 2>&1 >/dev/tty)

    for choice in $tools_choice; do
        case $choice in
            1) final_repo_list+=("${terminal_power_tools[@]}") ;;
            2) final_repo_list+=("${dev_tools[@]}"); dev_tools_selected=true ;;
        esac
    done

    local dm_choice; dm_choice=$(dialog --clear --title "Display Manager" --menu "Would you like to install a Display Manager (Login Screen)?" 16 70 5 \
            1 "SDDM (Recommended for Plasma/Qt)" \
            2 "GDM (Recommended for GNOME)" \
            3 "Ly (Lightweight, TUI-based, from AUR)" \
        4 "None (Login via TTY and start Hyprland manually)" 2>&1 >/dev/tty) || error_exit "Selection cancelled."

    case $dm_choice in
        1) final_repo_list+=("${dm_packages_sddm[@]}"); DM_SELECTED="sddm" ;;
        2) final_repo_list+=("${dm_packages_gdm[@]}"); DM_SELECTED="gdm" ;;
        3) final_aur_list+=("${dm_packages_ly[@]}"); DM_SELECTED="ly" ;;
        4) msg "Skipping Display Manager installation." ;;
        *) msg "Invalid choice, skipping Display Manager." ;;
    esac

    clear
    # --- Password Prompt and Installation Phase ---
    dialog --title "Sudo Password Required" --msgbox "The script now needs to run commands with sudo to install packages and enable system services.\n\nPlease enter your password when prompted." 10 70
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    dialog --title "Installation Summary" --infobox "Sudo credentials confirmed.\n\nThe installation process is about to begin. This may take some time. Please be patient." 8 70
    sleep 4

    # Step 1: Install packages from official repositories
    if [ ${#final_repo_list[@]} -gt 0 ]; then
        local pkgs_to_install_repo=()
        msg "Checking which official packages need to be installed..."
        for pkg in "${final_repo_list[@]}"; do
            if ! pacman -Q "$pkg" &> /dev/null; then
                pkgs_to_install_repo+=("$pkg")
            fi
        done

        if [ ${#pkgs_to_install_repo[@]} -gt 0 ]; then
            local title="Installing Official Packages (${#pkgs_to_install_repo[@]})"
            dialog --title "$title" --infobox "The following packages will be installed:\n\n${pkgs_to_install_repo[*]}" 10 70
            sleep 4
            { sudo pacman -S --needed --noconfirm "${pkgs_to_install_repo[@]}"; } 2>&1 | dialog --title "$title" --programbox "Starting pacman..." 20 100
        else
            dialog --title "Official Packages" --infobox "All required packages from official repositories are already installed. Skipping." 8 70
            sleep 3
        fi
    fi

    # Step 2: Install packages from AUR
    if [ ${#final_aur_list[@]} -gt 0 ]; then
        local pkgs_to_install_aur=()
        msg "Checking which AUR packages need to be installed..."
        # AUR helpers are smart, but this check provides consistent UI
        for pkg in "${final_aur_list[@]}"; do
            if ! pacman -Q "$pkg" &> /dev/null; then
                pkgs_to_install_aur+=("$pkg")
            fi
        done

        if [ ${#pkgs_to_install_aur[@]} -gt 0 ]; then
            local title="Installing AUR Packages (${#pkgs_to_install_aur[@]}) with $AUR_HELPER"
            dialog --title "$title" --infobox "The following packages will be installed from AUR:\n\n${pkgs_to_install_aur[*]}" 10 70
            sleep 4
            { "$AUR_HELPER" -S --needed --noconfirm "${pkgs_to_install_aur[@]}"; } 2>&1 | dialog --title "$title" --programbox "Starting $AUR_HELPER..." 20 100
        else
            dialog --title "AUR Packages" --infobox "All required packages from AUR are already installed. Skipping." 8 70
            sleep 3
        fi
    fi

    # --- Post-installation Phase ---
    clear
    separator
    msg "Running post-installation tasks..."
    separator
    if command -v xdg-user-dirs-update &> /dev/null; then msg "Creating standard user directories..."; xdg-user-dirs-update; fi
    if [ "$dev_tools_selected" = true ]; then
        msg "Configuring Docker..."; sudo systemctl enable --now docker.service; sudo usermod -aG docker "$USER"
        msg "User '$USER' has been added to the 'docker' group."; warn "You need to log out and log back in for this change to take effect."
    fi
    if [ -n "$DM_SELECTED" ]; then msg "Enabling '$DM_SELECTED' service..."; sudo systemctl enable "$DM_SELECTED.service"; fi

    dialog --title "Installation Complete" --msgbox "All tasks completed successfully! \n\nNext steps:\n1. Copy your dotfiles to their respective locations.\n2. Reboot the system to apply all changes." 12 70

    clear
    separator
    msg "Script finished."
}

# Run the main function
main
