#!/bin/bash
# Reemplaza el bloque entre "# BEGIN PYWAL THEME" y "# END PYWAL THEME"
# dentro de ~/.config/jellyfin-tui/config.yaml con lo que pywal acaba de generar.
# No toca el resto del archivo (credenciales, otras opciones, etc.)

CONFIG="$HOME/.config/jellyfin-tui/config.yaml"
THEME="$HOME/.cache/wal/jellyfin-tui-theme.yaml"

if [ ! -f "$CONFIG" ]; then
    echo "No encontre $CONFIG"
    exit 1
fi
if [ ! -f "$THEME" ]; then
    echo "No encontre $THEME (corriste wal -i alguna vez?)"
    exit 1
fi

python3 - "$CONFIG" "$THEME" << 'PYEOF'
import sys

config_path, theme_path = sys.argv[1], sys.argv[2]

with open(config_path) as f:
    config = f.read()
with open(theme_path) as f:
    theme_block = f.read().rstrip("\n") + "\n"

start_marker = "# BEGIN PYWAL THEME"
end_marker = "# END PYWAL THEME"

if start_marker in config and end_marker in config:
    pre = config.split(start_marker)[0]
    post = config.split(end_marker)[1]
    config = pre + theme_block + post.lstrip("\n")
else:
    if not config.endswith("\n"):
        config += "\n"
    config += "\n" + theme_block

with open(config_path, "w") as f:
    f.write(config)

print("Tema de jellyfin-tui actualizado.")
PYEOF
