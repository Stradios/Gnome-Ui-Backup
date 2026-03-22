#!/bin/bash
set -euo pipefail

# ─── Distro check ────────────────────────────────────────────────────────────
if [ -f /etc/os-release ]; then
    source /etc/os-release
    DISTRO="${ID:-unknown}"
else
    echo "❌ Cannot detect distro — /etc/os-release not found."
    exit 1
fi

echo "🖥️  Detected distro: $DISTRO"

case "$DISTRO" in
    arch | manjaro | endeavouros | garuda)
        PKG_MANAGER="pacman" ;;
    ubuntu | debian | pop | linuxmint | elementary)
        PKG_MANAGER="apt" ;;
    fedora)
        PKG_MANAGER="dnf" ;;
    opensuse* | suse)
        PKG_MANAGER="zypper" ;;
    *)
        echo "⚠️  Unsupported distro: $DISTRO. Backup will still run but package list may not restore correctly."
        PKG_MANAGER="unknown" ;;
esac

# ─── Backup ───────────────────────────────────────────────────────────────────
BACKUP_DIR="$HOME/gnome-ui-backup"

echo "📦 Creating backup folder..."
mkdir -p "$BACKUP_DIR"

# Save distro info so restore knows what package manager to use
echo "$DISTRO" > "$BACKUP_DIR/distro.txt"
echo "$PKG_MANAGER" > "$BACKUP_DIR/pkg_manager.txt"

echo "💾 Dumping GNOME appearance settings..."
dconf dump /org/gnome/shell/extensions/ > "$BACKUP_DIR/extensions-settings.ini"
dconf dump /org/gnome/desktop/interface/ > "$BACKUP_DIR/interface.ini"
dconf dump /org/gnome/desktop/wm/preferences/ > "$BACKUP_DIR/wm-preferences.ini"

echo "🧩 Saving enabled extensions list..."
gnome-extensions list --enabled > "$BACKUP_DIR/extensions.txt"

echo "📁 Copying extensions..."
if [ -d "$HOME/.local/share/gnome-shell/extensions" ]; then
    cp -r "$HOME/.local/share/gnome-shell/extensions" "$BACKUP_DIR/extensions"
else
    echo "⚠️  No extensions folder found, skipping."
fi

echo "🎨 Copying themes..."
[ -d "$HOME/.themes" ] && cp -r "$HOME/.themes" "$BACKUP_DIR/themes"

echo "🖼️  Copying icons..."
[ -d "$HOME/.icons" ] && cp -r "$HOME/.icons" "$BACKUP_DIR/icons"

echo "✅ UI backup complete at: $BACKUP_DIR"
