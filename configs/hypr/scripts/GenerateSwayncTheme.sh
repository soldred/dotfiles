#!/bin/bash

JSON=~/.cache/wal/colors.json
TEMPLATE=~/.config/swaync/style.template.css
OUTPUT=~/.config/swaync/style.css

if [ -f "$OUTPUT" ]; then
    rm -rf "$OUTPUT"
fi

background=$(jq -r '.special.background' "$JSON")
foreground=$(jq -r '.special.foreground' "$JSON")

for i in {0..15}; do
    eval color$i=$(jq -r ".colors.color$i" "$JSON")
done

SED_COMMAND="sed \
-e \"s/{{background}}/$background/g\" \
-e \"s/{{foreground}}/$foreground/g\""

for i in {0..15}; do
    eval COLOR_VALUE="\$color$i"
    SED_COMMAND+=' -e "s/{{color'$i'}}/'"$COLOR_VALUE"'/g"'
done

eval "$SED_COMMAND" "$TEMPLATE" > "$OUTPUT"

swaync-client -rs

