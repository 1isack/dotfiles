#!/bin/bash
FILE=/tmp/cava-lock-latest.txt
[ -f "$FILE" ] || { echo ""; exit 0; }

blocks=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
IFS=';' read -ra bars < "$FILE"

out=""
for b in "${bars[@]}"; do
    [ -z "$b" ] && continue
    out+="${blocks[$b]}"
done
echo "$out"
