# Get id of an active window
kill $(hyprctl activewindow | grep -o 'pid: [0-9]*' | cut -d' ' -f2)
