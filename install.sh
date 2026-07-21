#!/bin/bash
# install.sh -- backs up your dotfiles into ~/dotfiles using plain copies
# (no symlinks -- the live files in ~/.config stay real files).
#
# Usage:
#   ./install.sh backup    -> copy live configs into ~/dotfiles (for git)
#   ./install.sh restore   -> (on a NEW machine) copy from ~/dotfiles into place
#   ./install.sh packages  -> print pacman/AUR install commands
#
# Since everything is a plain cp, running "backup" again after editing a live
# config will overwrite the repo copy with the newer version -- that's the
# normal workflow: edit live, then re-run backup, then git commit.

set -euo pipefail

DOTFILES="$HOME/dotfiles"

# path pairs: "source-in-repo:destination-in-home"
PATHS=(
    "config/mango:.config/mango"
    "config/niri:.config/niri"
    "config/hypr:.config/hypr"
    "config/waybar:.config/waybar"
    "config/quickshell:.config/quickshell"
    "config/kitty:.config/kitty"
    "config/foot:.config/foot"
    "config/wlogout:.config/wlogout"
    "config/cava:.config/cava"
    "config/nvim:.config/nvim"
    "config/wal:.config/wal"
    "local/bin:.local/bin"
)

do_backup() {
    mkdir -p "$DOTFILES"
    echo "==> Copying live configs into $DOTFILES"
    for pair in "${PATHS[@]}"; do
        src="${pair%%:*}"
        dst="${pair##*:}"
        live="$HOME/$dst"
        repo="$DOTFILES/$src"

        if [ ! -e "$live" ]; then
            echo "  [skip] $dst does not exist on this machine"
            continue
        fi

        mkdir -p "$(dirname "$repo")"
        rm -rf "$repo"
        cp -r "$live" "$repo"
        echo "  [copied] $dst -> $repo"
    done
    echo "==> Done. cd ~/dotfiles && git add -A && git commit -m 'update rice'"
}

do_restore() {
    if [ ! -d "$DOTFILES" ]; then
        echo "No $DOTFILES found -- clone your repo there first."
        exit 1
    fi
    echo "==> Copying from $DOTFILES into place"
    for pair in "${PATHS[@]}"; do
        src="${pair%%:*}"
        dst="${pair##*:}"
        repo="$DOTFILES/$src"
        live="$HOME/$dst"

        [ -e "$repo" ] || continue
        mkdir -p "$(dirname "$live")"
        cp -r "$repo" "$live"
        echo "  [copied] $src -> $dst"
    done
    chmod +x "$HOME/.local/bin/"*.sh 2>/dev/null || true
    echo "==> Done."
}

do_packages() {
    cat << 'PKGS'
# Official repos
sudo pacman -S --needed \
    mango waybar quickshell kitty foot wlogout hyprlock wlogout \
    grim slurp wl-clipboard swaybg awww jq brightnessctl \
    pipewire pipewire-pulse wireplumber playerctl cava \
    python-pywal gpu-screen-recorder libva-nvidia-driver \
    neovim swayimg xdg-desktop-portal

# AUR (yay/paru)
yay -S --needed \
    xwayland-satellite bibata-cursor-theme-bin \
    nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils

# kew: build from source, NOT the pacman package (it ships without dbus support)
git clone https://codeberg.org/ravachol/kew.git
cd kew && make USE_DBUS=1 && doas make install
PKGS
}

case "${1:-}" in
    backup)   do_backup ;;
    restore)  do_restore ;;
    packages) do_packages ;;
    *)
        echo "Usage: $0 {backup|restore|packages}"
        exit 1
        ;;
esac
