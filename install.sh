#!/usr/bin/env bash
# Install this Hyprland + Quickshell setup into $HOME.
#
# Default: copy config files, backing up anything already there.
# --packages: also install the required Arch packages with pacman.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.dotfiles-backup-$STAMP"

PACKAGES=(
    hyprland
    hyprpaper
    hyprshot
    hyprlock
    hyprpolkitagent
    quickshell
    kitty
    dolphin
    cliphist
    wl-clipboard
    grim
    slurp
    playerctl
    wireplumber
    pipewire
    pipewire-pulse
    pipewire-alsa
    qt5ct
    qt6ct
    ttf-jetbrains-mono
    jq
    python
    networkmanager
    bluez
    bluez-utils
    xdg-desktop-portal-hyprland
    polkit
    imagemagick
)

FILES=(
    .config/hypr
    .config/quickshell
    .config/kitty
    .config/qt5ct
    .config/qt6ct
    .config/kdeglobals
    .config/dolphinrc
    .config/mimeapps.list
    .local/bin/hypr-binds-gen
    .local/bin/theme-sync
    .local/bin/take-screenshot
    .local/bin/copy-image
    .local/bin/x11-clipboard-image
    .bashrc
    .bash_profile
    .bash_logout
    .fonts/Roboto-Medium.ttf
    .fonts/Roboto-Regular.ttf
    Pictures/Wallpapers/courtyard.jpg
)

usage() {
    cat <<'EOF'
Usage: ./install.sh [--packages]

  --packages   Install required Arch packages first (uses sudo/pacman).
  -h, --help   Show this help.

Existing files are moved to ~/.dotfiles-backup-<timestamp> before install.
EOF
}

install_packages() {
    if ! command -v pacman >/dev/null 2>&1; then
        echo "install.sh: pacman not found, skipping package install." >&2
        return
    fi
    echo "==> Installing packages"
    sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
}

install_path() {
    local rel="$1"
    local src="$ROOT/$rel"
    local dest="$HOME/$rel"

    if [[ ! -e "$src" ]]; then
        echo "install.sh: missing $rel in repo, skipping." >&2
        return
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
        mkdir -p "$BACKUP/$(dirname "$rel")"
        cp -a "$dest" "$BACKUP/$rel"
        rm -rf "$dest"
    fi

    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
    echo "  $rel"
}

DO_PACKAGES=0
for arg in "$@"; do
    case "$arg" in
        --packages) DO_PACKAGES=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "install.sh: unknown argument: $arg" >&2; usage; exit 1 ;;
    esac
done

if [[ "$ROOT" == "$HOME" ]]; then
    echo "install.sh: run this from the cloned dotfiles repo, not from \$HOME." >&2
    exit 1
fi

if [[ "$DO_PACKAGES" -eq 1 ]]; then
    install_packages
fi

echo "==> Installing dotfiles into $HOME"
for rel in "${FILES[@]}"; do
    install_path "$rel"
done

# hyprpaper wants an absolute path; rewrite the author's home for this machine.
if [[ -f "$HOME/.config/hypr/hyprpaper.conf" ]]; then
    sed -i "s|/home/thefi|$HOME|g" "$HOME/.config/hypr/hyprpaper.conf"
fi

chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

# Regenerate derived files so the checkout matches the target machine.
if command -v python3 >/dev/null 2>&1; then
    "$HOME/.local/bin/hypr-binds-gen" || true
    "$HOME/.local/bin/theme-sync" || true
fi

if [[ -d "$BACKUP" ]]; then
    echo "==> Previous files backed up to $BACKUP"
fi

cat <<'EOF'

==> Done.

Next steps:
  1. Log out and start Hyprland (or restart the session).
  2. Optional extras: hyprland plugins, Telegram, browsers, etc. are not installed.

EOF
