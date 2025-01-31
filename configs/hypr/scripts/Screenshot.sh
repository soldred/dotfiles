#!/usr/bin/env bash

outputDir="$HOME/Pictures/Screenshots/"
outputFile="screenshot_$(date +%d-%m-%Y_%H-%M-%S).png"
outputPath="$outputDir/$outputFile"
mkdir -p "$outputDir"

mode=${1:-area}

case "$mode" in
active)
    command="grimblast copysave active $outputPath"
    ;;
output)
    command="grimblast copysave output $outputPath"
    ;;
area)
    command="grimblast copysave area $outputPath"
    ;;
*)
    echo "Invalid option: $mode"
    echo "Usage: $0 {active|output|area}"
    exit 1
    ;;
esac

if eval "$command"; then
    recentFile=$(find "$outputDir" -name 'screenshot_*.png' -printf '%T+ %p\n' | sort -r | head -n 1 | cut -d' ' -f2-)
    notify-send "Grimblast" "Your screenshot has been saved." \
        -i video-x-generic \
        -a "Grimblast" \
        -t 7000 \
        -u normal \
        --action="scriptAction:-xdg-open $outputDir=Directory" \
        --action="scriptAction:-xdg-open $recentFile=View" \
	--action="scriptAction:-gimp -n $recentFile=Edit "
fi

