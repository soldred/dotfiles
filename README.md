Welcome to my personal Hyprland dotfiles repository! This setup is meticulously crafted for a minimal, fast, and aesthetically pleasing experience on Arch Linux.

<p>https://github.com/user-attachments/assets/02d4b42e-1440-4f0d-b65d-26c503ca034c</p>

## ✨ Features

*   **Modern & Minimal:** A clean and beautiful desktop environment powered by Hyprland.
*   **Highly Scripted:** Automated installation and setup scripts to get you up and running quickly.
*   **Modular & Customizable:** Easily tweak themes, animations, and settings to your liking.
*   **Efficient Workflow:** Thoughtful keybindings and powerful tools like `zsh`, `rofi`, and `ags` to boost your productivity.
*   **Complete Theming:** Cohesive look and feel across GTK, Qt, and terminal applications.

## ⚙️ Core Components & Utilities

This setup is built from a collection of powerful and lightweight components. Here's a breakdown of the key software used:

| Category          | Component(s)                                   | Description                                                     |
| ----------------- | ---------------------------------------------- | --------------------------------------------------------------- |
| **Visual Core**   | `Hyprland`                                     | The heart of the desktop; a dynamic tiling Wayland compositor.  |
|                   | `ags-hyprpanel-git`                            | The top status bar, built with [AGS](https://github.com/Aylur/ags) (A Gtk-based Shell). |
|                   | `Rofi` (Wayland Fork)                          | Application launcher, run dialog, and window switcher.          |
|                   | `hyprlock` & `hypridle`                        | Manages the lock screen and system idle states.                 |
|                   | `swww`                                         | An efficient wallpaper daemon for Wayland, handles animations.  |
|                   | `Waypaper`                                     | A GUI frontend for selecting wallpapers (uses `swww` backend).  |
| **Applications**  | `Kitty`                                        | A fast, feature-rich, GPU-accelerated terminal emulator.        |
|                   | `Nautilus`                                     | The default file manager (from GNOME).                          |
|                   | `Neovim`                                       | The primary command-line text editor.                           |
| **Utilities**     | `grimshot`                                     | Script for taking screenshots (uses `grim` and `slurp`).        |
|                   | `Btop`                                         | A modern and interactive system resource monitor.               |
|                   | `pavucontrol`                                  | A graphical mixer for managing audio devices and volume.        |
|                   | `Polkit Gnome Agent`                           | Handles privilege escalation prompts for graphical apps.        |
| **Shell**         | `Zsh` + `Starship`                             | The default shell and its highly customizable prompt.           |

## 🚀 Installation

**🛑 Important Warning:** These are my personal dotfiles. Running these scripts will **overwrite** your existing configurations. Always back up your important data and dotfiles before proceeding. I am not responsible for any data loss or system instability.

### Step 1: Clone the Repository

First, clone this repository to your local machine and navigate into the directory.

```bash
git clone https://github.com/yehorych13/dotfiles && cd dotfiles
```

### Step 2: Install the interactive Installer

The `install.sh` script is now an all-in-one interactive installer. It will handle everything from system dependencies to dotfile deployment.

Simply make the script executable and run it:
```bash
chmod +x install.sh
./install.sh
```

The script will guide you through the following process:
1. **Package installation**: It will first ask if you want to run the system package installer (`install_packages.sh`). This is highly recommended for a fresh setup to install all necessary applications, drivers, and an AUR helper.

2. **Dotfiles Deployment**: Next, it will prompt you to select which components to install (configs, themes, wallpapers). It will safely back up any of your existing configurations to `$HOME/.config_backup_$(date "+%Y-%m-%d_%H-%M-%S")` before creating symbolic links.

### Step 3: Final Setup

A few final steps are needed to complete the installation.

1.  **Set Zsh as default shell:**
    ```bash
    chsh -s $(which zsh)
    ```
    *You will need to log out and log back in for this change to take effect.*

2.  **Reboot:**
    Once the scripts are finished, reboot your system to apply all changes and start your new Hyprland session.
    ```bash
    sudo reboot
    ```

## 🎨 Post-Installation & Customization

*   **Display Manager (Login Screen):** If you chose SDDM during installation, it is highly recommended to install the [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) to achieve a matching look.

*   **Wallpapers:** After logging in, launch `waypaper` to select and set your wallpaper. You can open it via the application menu (`SUPER + R`).

*   **Keyboard Remapping (Optional):** If you want to use my `kanata` configuration (which remaps `Caps Lock` to `Esc` on tap and `Ctrl` on hold), follow the setup guide [here](https://github.com/jtroo/kanata/blob/main/docs/setup-linux.md).

## ⌨️ Keybindings

This setup uses `SUPER` (Windows/Command key) as the main modifier.

| Description                               | Keybinding                            | Alternative                               |
| ----------------------------------------- | ------------------------------------- | ----------------------------------------- |
| **Window & Workspace Management**         |                                       |                                           |
| Kill active window                        | `SUPER + Q`                           |                                           |
| Force-kill active window                  | `SUPER + SHIFT + Q`                   |                                           |
| Toggle floating mode                      | `SUPER + T`                           |                                           |
| Toggle fullscreen mode                    | `SUPER + F`                           |                                           |
| Move focus                                | `SUPER + Arrow Keys`                  |                                           |
| Switch between workspaces                 | `SUPER + 1..9, 0`                     |                                           |
| Move active window to workspace           | `SUPER + SHIFT + 1..9, 0`             |                                           |
| Toggle special workspace (scratchpad)     | `SUPER + S`                           |                                           |
| **Applications & Utilities**              |                                       |                                           |
| Open terminal (`kitty`)                   | `SUPER + ENTER`                       |                                           |
| Open file manager (`nautilus`)            | `SUPER + E`                           |                                           |
| Open browser (`firefox`)                  | `SUPER + B`                           |                                           |
| Open application launcher (`rofi`)        | `SUPER + R`                           |                                           |
| **System & Theming**                      |                                       |                                           |
| Take a screenshot (interactive)           | `SUPER + SHIFT + S`                   |                                           |
| Open theme selector                       | `SUPER + ALT + T`                     |                                           |
| Open animation style selector             | `SUPER + ALT + A`                     |                                           |
| Exit Hyprland session                     | `SUPER + SHIFT + DELETE`              |                                           |
| **Mouse Bindings**                        |                                       |                                           |
| Move window                               | `SUPER + Left Mouse Button`           | `Mouse Button 5` (if available)           |
| Resize window                             | `SUPER + Right Mouse Button`          | `Mouse Button 4` (if available)           |

---
Enjoy your new setup! If you find any issues or have suggestions, feel free to open an issue.

