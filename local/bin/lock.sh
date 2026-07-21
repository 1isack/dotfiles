#!/bin/bash
FIFO=/tmp/cava-lock.fifo
[ -p "$FIFO" ] || mkfifo "$FIFO"

cava -p ~/.config/cava/lock-config &
CAVA_PID=$!

( while read -r line; do echo "$line" > /tmp/cava-lock-latest.txt; done < "$FIFO" ) &
READER_PID=$!

hyprlock

kill "$CAVA_PID" "$READER_PID" 2>/dev/null
rm -f /tmp/cava-lock-latest.txt
