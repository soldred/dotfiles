#!/bin/bash

# This script is only for my ASUS laptop
MONITOR="eDP-1"
RES="2880x1800"
SCALE="2"

AC_NAME=$(ls /sys/class/power_supply | grep -E 'AC|ADP' | head -n 1)
POWER="/sys/class/power_supply/$AC_NAME/online"

FREQ_AC="120"
FREQ_BAT="60"

set_rate(){
    if [ -f "$POWER" ]; then
        STATUS=$(cat "$POWER")
    else
        STATUS="1"
    fi

    if [ "$STATUS" = "1" ]; then
        TARGET="$FREQ_AC"
    else
        TARGET="$FREQ_BAT"
    fi

    hyprctl keyword monitor "$MONITOR,${RES}@${TARGET},auto,$SCALE" > /dev/null

    echo "$(date): Set ${TARGET}Hz on $MONITOR"
}

set_rate

acpi_listen | while read -r event; do
    [[ "$event" == *ac_adapter* ]] || continue

    sleep 0.5
    set_rate
done
