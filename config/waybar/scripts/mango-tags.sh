#!/bin/bash
# Stream continuo de tags de Mango para el custom module de waybar.
# Requiere: jq
# Colores tomados en vivo de pywal (se leen al arrancar el script)
source ~/.cache/wal/colors.sh

mmsg watch all-monitors 2>/dev/null | while read -r line; do
    echo "$line" | jq -r --arg active "$color4" --arg bg "$background" --arg fg "$foreground" --arg urgent "$color1" '
        .monitors[0].tags
        | map(
            if .is_urgent then
                "<span background=\"" + $urgent + "\" foreground=\"" + $bg + "\"> " + (.index|tostring) + " </span>"
            elif .is_active then
                "<span background=\"" + $active + "\" foreground=\"" + $bg + "\"> " + (.index|tostring) + " </span>"
            elif .client_count > 0 then
                "<span foreground=\"" + $fg + "\"> " + (.index|tostring) + " </span>"
            else empty
            end
          )
        | join(" ")
    '
done
