# .dotfiles

Minimalist, clean, and fast Hyprland setup. My goal was to create a focused workspace that stays out of the way while remaining functional and aesthetically pleasing.

## ✨ Features

- **Dynamic Palettes:** All system colors (terminal, bar, launcher) are automatically generated from your current wallpaper via pywal16.
- **Highly Scripted:** A lot of different QoL scripts, like screenshot, powersaver mode(works only on my laptop for now), selectors and much more.
- **Efficient Workflow:** Thoughtful keybindings and powerful tools like `zsh`, `rofi` to boost your productivity.
- **As little bloat as possible:** Only the essential tools needed for daily use.

## 🛠️ The Setup

This configuration is built for performance and simplicity on Arch Linux. Instead of heavy "eye-candy" widgets, it uses smart scripting to maintain a cohesive look.

- **Theming**: pywal16 (Dynamic color generation from wallpapers)

- **Wallpaper**: swww (Fast and efficient wallpaper daemon)

- **Status Bar**: Waybar (Lightweight and CSS-customizable)

- **Launcher**: Rofi-Wayland (Minimalist app launcher with image thumbnails)

- **Terminal**: Kitty (GPU-accelerated, configured for speed)

- **File manager**: Thunar (simple, reliable)

## 🚀 Installation

**Installation script is currently under development**, so until that, do everything manually

### Step 1: Clone the Repository and install packages

First, clone this repository to your local machine and navigate into the directory.

```bash
git clone https://github.com/soldred/dotfiles && cd dotfiles
```

Then install packages provided in packages.txt file

### Step 2: Copy configs

Go inside `dotfiles/configs` folder, copy everything from here to `~/.config/` folder. Also, do not forget to copy `dotfiles/configs/zsh/.zshenv` to your home directory.

### Step 3: Final Setup

A few final steps are needed to complete the installation.

1. **Set Zsh as default shell:**

   ```bash
   chsh -s $(which zsh)
   ```

   _You will need to log out and log back in for this change to take effect._

2. **Reboot:**
   Reboot your system to apply all changes and start your new Hyprland session.

   ```bash
   sudo reboot

   start-hyprland
   ```

3. To be able to set the wallpaper using a script(with rofi), be sure to save it in `~/Pictures/Wallpapers/`

## ⌨️ Keybindings

This setup uses `SUPER` (Windows/Command key) as the main modifier.

| Description                           | Keybinding                   | Alternative                     |
| ------------------------------------- | ---------------------------- | ------------------------------- |
| **Window & Workspace Management**     |                              |                                 |
| Kill active window                    | `SUPER + Q`                  |                                 |
| Toggle floating mode                  | `SUPER + T`                  |                                 |
| Toggle fullscreen mode                | `SUPER + F`                  |                                 |
| Move focus                            | `SUPER + h,j,k,l`            |                                 |
| Resize window                         | `SUPER + SHIFT + h,j,k,l`    |                                 |
| Switch between workspaces             | `SUPER + 1..9, 0`            |                                 |
| Move active window to workspace       | `SUPER + SHIFT + 1..9, 0`    |                                 |
| Toggle special workspace (scratchpad) | `SUPER + S`                  |                                 |
| **Applications & Utilities**          |                              |                                 |
| Open terminal (`kitty`)               | `SUPER + ENTER`              |                                 |
| Open file manager (`thunar`)          | `SUPER + E`                  |                                 |
| Open browser (`firefox`)              | `SUPER + B`                  |                                 |
| Open application launcher (`rofi`)    | `SUPER + SPACE`              |                                 |
| **System & Theming**                  |                              |                                 |
| Take a screenshot (interactive)       | `SUPER + SHIFT + S`          |                                 |
| Open animation style selector         | `SUPER + A`                  |                                 |
| Open wallpaper selector               | `SUPER + W`                  |                                 |
| Reload waybar                         | `SUPER + SHIFT + W`          |                                 |
| Clibpoard history                     | `SUPER + V`                  |                                 |
| Lock screen                           | `SUPER + DELETE`             |                                 |
| Exit Hyprland session                 | `SUPER + SHIFT + DELETE`     |                                 |
| **Mouse Bindings**                    |                              |                                 |
| Move window                           | `SUPER + Left Mouse Button`  | `Mouse Button 5` (if available) |
| Resize window                         | `SUPER + Right Mouse Button` | `Mouse Button 4` (if available) |
