#!/bin/bash
if pgrep -f "quickshell -c music-widget" > /dev/null; then
    pkill -f "quickshell -c music-widget"
else
    quickshell -c music-widget &
fi
