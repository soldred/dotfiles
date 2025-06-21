#!/bin/bash

# Check for color support
if tput colors &> /dev/null && [ "$(tput colors)" -ge 256 ]; then
    # Set colors using tput
    RED="$(tput setaf 160)"
    GREEN="$(tput setaf 46)"
    BLUE="$(tput setaf 39)"
    YELLOW="$(tput setaf 226)"
    ORANGE="$(tput setaf 202)"
    CYAN="$(tput setaf 51)"
    RESET="$(tput sgr0)"
else
    # If no color support, reset to default
    RESET=""
    RED=""
    GREEN=""
    BLUE=""
    YELLOW=""
    ORANGE=""
    CYAN=""
fi

# Install yay if it's not found
if ! command -v yay &> /dev/null; then
    echo -e "${YELLOW}yay not found. Installing yay...${RESET}"
    sudo pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
fi

# Package arrays
base_packages=(
    base-devel
    git
    curl
    wget
    unzip
    less
)

hyprland_packages=(
    hyprland
    hyprlock
    hypridle
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xdg-user-dirs
    xorg-xwayland
    xorg-xhost
    wl-clipboard
    polkit
    polkit-gnome
    gnome-keyring
    pipewire
    pipewire-pulse
    pipewire-alsa
    wireplumber
    sof-firmware
)

ui_packages=(
    gtk3
    gtk4
    libdbusmenu-gtk3
    gtk-engine-murrine
    sassc
    qt5-wayland
    qt6-wayland
    qt5ct
    qt6ct
    kvantum
)

font_packages=(
    ttf-jetbrains-mono-nerd
    ttf-ubuntu-nerd
    ttf-roboto
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
)

dm_packages=(
)

apps_packages=(
    nautilus
    gvfs
    gvfs-gphoto2
    kitty
    neovim
    gimp
    loupe
    mpv
    btop
    rofi-wayland
    pavucontrol
    waypaper
    wf-recorder
    gpu-screen-recorder
    grimshot
    hyprpicker
    ags-hyprpanel-git
    python-pywal16
    matugen
    better-control-git
    discord
)

terminal_packages=(
    zsh
    ripgrep
    fd
    make
    gcc
    zoxide
    eza
    starship
)

gpu_packages=(
    mesa
    lib32-mesa
    vulkan-radeon
    vulkan-icd-loader
    lib32-vulkan-radeon
    libva-mesa-driver
    libva-utils
)

dev_packages=(
    docker
    docker-compose
    github-cli
)

# Combined list of all packages
all_packages=(
    "${base_packages[@]}"
    "${hyprland_packages[@]}"
    "${ui_packages[@]}"
    "${font_packages[@]}"
    "${dm_packages[@]}"
    "${apps_packages[@]}"
    "${terminal_packages[@]}"
    "${gpu_packages[@]}"
    "${dev_packages[@]}"
)

# Arrays to store valid and invalid packages
valid_packages=()
invalid_packages=()

echo -e "${BLUE}Checking available packages...${RESET}"

# Check if each package exists using yay
for pkg in "${all_packages[@]}"; do
    if yay -Si "$pkg" &> /dev/null || yay -Ss "^$pkg$" | grep -q "^aur/"; then
        valid_packages+=("$pkg")
    else
        invalid_packages+=("$pkg")
    fi
done

# Install found packages without confirmation
echo -e "${YELLOW}Installing found packages...${RESET}"
yay -S --needed --noconfirm --answerdiff=None --answerclean=None "${valid_packages[@]}"

# Output the list of missing packages
if [ ${#invalid_packages[@]} -ne 0 ]; then
    echo ""
    echo -e "${RED}The following packages were not found in the repositories or AUR:${RESET}"
    for pkg in "${invalid_packages[@]}"; do
        echo -e "  - $pkg"
    done
fi

echo ""
echo -e "${GREEN}Done! All found packages have been installed.${RESET}"

