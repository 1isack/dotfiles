#!/bin/bash
NEW_WALL="$1"

awww img "$NEW_WALL" --transition-type grow --transition-fps 60 --transition-duration 1.2
sleep 1.5

if ! pgrep -f "gpu-screen-recorder" > /dev/null; then
    wal -i "$NEW_WALL" -n
    pkill -f waybar
    sleep 0.3
    waybar-launcher.sh &
    if pgrep -u $USER kitty > /dev/null; then
        kill -SIGUSR1 $(pgrep -u $USER kitty)
    fi
    pkill -USR1 nvim
    /home/isaak/.local/bin/update-jellyfin-theme.sh
    cat <<'INNEREOF' > "$HOME/.config/cava/config"
[general]
framerate = 60
autosens = 1
bar_spacing = 0
[input]
method = pipewire
source = auto
[output]
method = ncurses
channels = stereo
[color]
gradient = 1
gradient_color_1 = 'COLOR1'
gradient_color_2 = 'COLOR2'
#gradient_color_3 = 'COLOR3'
#gradient_color_4 = 'COLOR4'
#gradient_color_5 = 'COLOR5'
[smoothing]
noise_reduction = 55
monstercat = 1
INNEREOF
    sed -i "s/COLOR1/$(sed -n '5p' ~/.cache/wal/colors)/" "$HOME/.config/cava/config"
    sed -i "s/COLOR2/$(sed -n '6p' ~/.cache/wal/colors)/" "$HOME/.config/cava/config"
    sed -i "s/COLOR3/$(sed -n '7p' ~/.cache/wal/colors)/" "$HOME/.config/cava/config"
    sed -i "s/COLOR4/$(sed -n '8p' ~/.cache/wal/colors)/" "$HOME/.config/cava/config"
    sed -i "s/COLOR5/$(sed -n '16p' ~/.cache/wal/colors)/" "$HOME/.config/cava/config"
    if pgrep -x "cava" > /dev/null; then
        killall -USR2 cava
    fi
    /home/isaak/.local/bin/mako-pywal.sh
else
    wal -i "$NEW_WALL" -n --backend wal
    /home/isaak/.local/bin/mako-pywal.sh
fi
