#!/bin/bash
# Replaces any symlink pointing into ~/dotfiles with a real copy of the file.
DOTFILES="$HOME/dotfiles"

PATHS=(
    ".config/mango" ".config/niri" ".config/hypr" ".config/waybar"
    ".config/quickshell" ".config/kitty" ".config/foot" ".config/wlogout"
    ".config/cava" ".config/nvim" ".config/wal" ".local/bin"
)

for p in "${PATHS[@]}"; do
    target="$HOME/$p"
    if [ -L "$target" ]; then
        real="$(readlink -f "$target")"
        rm "$target"
        cp -r "$real" "$target"
        echo "[restored] $p (was -> $real)"
    fi
done
