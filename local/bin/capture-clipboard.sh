#!/bin/bash
# Left click (no argument or "photo"): region screenshot -> clipboard + file
# Right click ("video"): toggle region recording with audio -> file
MODE="$1"

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
VIDEO_DIR="$HOME/Videos/ScreenRecords"
mkdir -p "$SCREENSHOT_DIR" "$VIDEO_DIR"
PIDFILE="/tmp/gsr-record.pid"

if [ "$MODE" = "video" ]; then
    if [ -f "$PIDFILE" ]; then
        # Already recording -> stop and save
        pkill -SIGINT -f "^gpu-screen-recorder"
        rm -f "$PIDFILE"
        notify-send -i video-x-generic "Recording stopped" "Saved to $VIDEO_DIR" 2>/dev/null
    else
        REGION="$(slurp -f "%wx%h+%x+%y")"
        [ -z "$REGION" ] && exit 0
        FILE="$VIDEO_DIR/$(date +%Y-%m-%d_%H-%M-%S).mp4"
        
        # -a default_output (sonido de la PC) y -a default_input (tu micrófono)
        gpu-screen-recorder -w "$REGION" -f 60 -a default_output -a default_input -o "$FILE" -fallback-cpu-encoding yes &
        
        echo $! > "$PIDFILE"
        notify-send -i video-x-generic "Recording started" "$(basename "$FILE")" 2>/dev/null
    fi
else
    FILE="$SCREENSHOT_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
    grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE"
    if [ -f "$FILE" ]; then
        notify-send -i "$FILE" "Screenshot captured" "Copied to clipboard and saved to $SCREENSHOT_DIR" 2>/dev/null
    fi
fi
