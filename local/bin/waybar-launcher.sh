#!/bin/bash
# Detects the running compositor and launches waybar with the matching config.
CONFIG_DIR="$HOME/.config/waybar"

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    exec waybar -c "$CONFIG_DIR/config-hyprland.jsonc" -s "$CONFIG_DIR/style.css"
elif [ -n "$NIRI_SOCKET" ]; then
    exec waybar -c "$CONFIG_DIR/config-niri.jsonc" -s "$CONFIG_DIR/style.css"
elif pgrep -x mango > /dev/null; then
    exec waybar -c "$CONFIG_DIR/config-mango.jsonc" -s "$CONFIG_DIR/style.css"
else
    # Fallback: default to mango's config
    exec waybar -c "$CONFIG_DIR/config-mango.jsonc" -s "$CONFIG_DIR/style.css"
fi
