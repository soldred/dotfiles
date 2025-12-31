#!/bin/bash

SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"

TEMP_DIR="/tmp"
TEMP_NAME="screenshot_$(date +%s).png"
TEMP_FILE="$TEMP_DIR/$TEMP_NAME"
EDITOR="swappy -f"

if [ -z "$1" ]; then
    echo "ERROR: Specify mode"
    echo "Use: $0 [region | output]"
    exit 1
fi

MODE="$1"

cleanup() {
    if [ -f "$TEMP_FILE" ] && [ "$SAVED" != "true" ]; then
        rm "$TEMP_FILE"
    fi
}
trap cleanup EXIT

case "$MODE" in
    region)
        hyprshot -m region -s -z -o "$TEMP_DIR" -f "$TEMP_NAME"
        ;;

    output)
        hyprshot -m output -s -o "$TEMP_DIR" -f "$TEMP_NAME"
        ;;

    *)
        echo "ERROR: Unknown mode"
        exit 1
        ;;
esac

if [ ! -f "$TEMP_FILE" ]; then
    exit 0
fi

wl-copy < "$TEMP_FILE"

ACTION=$(notify-send "Screenshot Taken" "Copied to clipboard" \
        -i "$TEMP_FILE" \
        --action="save=  Save" \
        --action="edit=  Edit" \
    --wait)

case "$ACTION" in
    "save")
        FINAL_PATH="$SAVE_DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
        mv "$TEMP_FILE" "$FINAL_PATH"
        SAVED="true"
        notify-send "Saved" "File: $FINAL_PATH" -i "$FINAL_PATH"
        ;;

    "edit")
        $EDITOR "$TEMP_FILE"
        SAVED="true"
        ;;

    *)
        ;;
esac
