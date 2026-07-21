#!/bin/bash
player=$(playerctl -l 2>/dev/null | head -n1)

if [ -z "$player" ]; then
    echo ""
    exit 0
fi

status=$(playerctl -p "$player" status 2>/dev/null)
artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
title=$(playerctl -p "$player" metadata title 2>/dev/null)

if [ "$status" = "Playing" ]; then
    echo " $artist - $title"
elif [ "$status" = "Paused" ]; then
    echo " $artist - $title"
else
    echo ""
fi
