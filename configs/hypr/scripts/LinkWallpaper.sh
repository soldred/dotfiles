#!/bin/bash

WALLPAPER="$1"
LINK_PATH="$HOME/.config/hypr/wallpaper"

ln -snf $WALLPAPER $LINK_PATH

