#!/usr/bin/bash

outputDir="$HOME/Pictures/Screenshots/"
outputFile="screenshot_$(date +%d-%m-%Y_%H-%M-%S).png"
outputPath="$outputDir/$outputFile"
mkdir -p "$outputDir"

mode=${1:-area}

# Modes availiable
# active - Captures the currently active window
# screen - Captures the entire screen. This includes all visible outputs
# area - Allows manually selecting a rectangular region, and captures that
# window - Allows manually selecting a rectangular region, and captures that
# output - Captures the currently active output
# anything - Allows manually selecting a single window (by clicking on it), an output (by clicking outside of all windows, e.g. on the status bar), or an area (by using click and drag).

if grimshot savecopy "$mode" "$outputPath"; then
    recentFile=$(find "$outputDir" -name 'screenshot_*.png' -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d' ' -f2-)
    notify-send "Grimbshot" "Your screenshot has been saved." \
        -i video-x-generic \
        -a "Grimshot" \
        -t 7000 \
        -u normal \
        --action="scriptAction:-xdg-open $outputDir=Directory" \
        --action="scriptAction:-xdg-open $recentFile=View" \
        --action="scriptAction:-ksnip $recentFile=Edit "
else
    echo "Screenshot failed! Command output:"
    grimshot savecopy "$mode" "$outputPath" 2>&1
fi
