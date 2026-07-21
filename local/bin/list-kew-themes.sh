#!/bin/bash
ls ~/.config/kew/themes/
echo "---"
cat ~/.config/kew/themes/nord.theme 2>/dev/null || cat ~/.config/kew/themes/*.theme | head -30
