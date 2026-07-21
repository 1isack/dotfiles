#!/bin/bash
# Muestra el layout de teclado activo (2 letras, minuscula) leyendo el IPC de Mango
mmsg watch all-monitors 2>/dev/null | while read -r line; do
    echo "$line" | jq -r '.monitors[0].keyboardlayout' | cut -c1-2 | tr '[:upper:]' '[:lower:]'
done
