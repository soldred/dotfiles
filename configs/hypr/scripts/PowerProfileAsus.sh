#!/bin/bash

get_current_profile() {
    asusctl profile -p 2>/dev/null | grep "Active profile is" | awk '{print $NF}'
}

if [ "$1" = "Next" ]; then
    CURRENT=$(get_current_profile)

    case "$CURRENT" in
        "Quiet")       NEXT="Balanced" ;;
        "Balanced")    NEXT="Performance" ;;
        "Performance") NEXT="Quiet" ;;
        *)             NEXT="Quiet" ;;
    esac

    asusctl profile -P "$NEXT"
    pkill -SIGRTMIN+8 waybar
    exit 0
fi

CURRENT=$(get_current_profile)

case "$CURRENT" in
    "Quiet")
        TEXT="Quiet"
        CLASS="quiet"
        ;;
    "Balanced")
        TEXT="Balanced"
        CLASS="balanced"
        ;;
    "Performance")
        TEXT="Performance"
        CLASS="performance"
        ;;
    *)
        TEXT="$CURRENT"
        CLASS="unknown"
        ;;
esac

echo "{\"text\": \"$TEXT\", \"class\": \"$CLASS\"}"

