#!/bin/bash
set -euo pipefail

BACKUP_DIR="$HOME/gnome-ui-backup"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup folder not found at: $BACKUP_DIR"
    exit 1
fi

# ─── Distro check ────────────────────────────────────────────────────────────
if [ -f /etc/os-release ]; then
    source /etc/os-release
    DISTRO="${ID:-unknown}"
else
    echo "❌ Cannot detect distro — /etc/os-release not found."
    exit 1
fi

echo "🖥️  Detected distro: $DISTRO"

# Cross-check with what was backed up
BACKUP_DISTRO="$(cat "$BACKUP_DIR/distro.txt" 2>/dev/null || echo "unknown")"
if [ "$DISTRO" != "$BACKUP_DISTRO" ]; then
    echo "⚠️  Warning: backup was made on '$BACKUP_DISTRO', restoring on '$DISTRO'."
    echo "   Themes, icons and extensions should still work, but package names may differ."
fi

# ─── Package manager helpers ─────────────────────────────────────────────────
install_pkg() {
    local pkg="$1"
    echo "📦 Installing: $pkg"
    case "$DISTRO" in
        arch | manjaro | endeavouros | garuda)
            sudo pacman -S --needed --noconfirm "$pkg" ;;
        ubuntu | debian | pop | linuxmint | elementary)
            sudo apt install -y "$pkg" ;;
        fedora)
            sudo dnf install -y "$pkg" ;;
        opensuse* | suse)
            sudo zypper install -y "$pkg" ;;
        *)
            echo "⚠️  Unknown distro — please install '$pkg' manually."
            return 1 ;;
    esac
}

pkg_installed() {
    command -v "$1" &>/dev/null
}

# ─── GNOME Tweaks ────────────────────────────────────────────────────────────
echo "🔧 Checking GNOME Tweaks..."
if ! pkg_installed gnome-tweaks; then
    echo "   Not found — installing..."
    case "$DISTRO" in
        arch | manjaro | endeavouros | garuda)
            install_pkg gnome-tweaks ;;
        ubuntu | debian | pop | linuxmint | elementary)
            install_pkg gnome-tweaks ;;
        fedora)
            install_pkg gnome-tweaks ;;
        opensuse* | suse)
            install_pkg gnome-tweaks ;;
        *)
            echo "⚠️  Please install GNOME Tweaks manually for your distro." ;;
    esac
else
    echo "   ✔ Already installed."
fi

# ─── Segoe UI font ───────────────────────────────────────────────────────────
echo "🔤 Checking Segoe UI font..."
FONT_DIR="$HOME/.local/share/fonts"
if fc-list | grep -qi "Segoe UI"; then
    echo "   ✔ Segoe UI already installed."
else
    echo "   Not found — downloading and installing from mrbvrz/segoe-ui-linux..."

    # Ensure wget is available
    if ! pkg_installed wget; then
        install_pkg wget
    fi

    FONT_TMP="$(mktemp -d)"
    trap 'rm -rf "$FONT_TMP"' EXIT

    wget -q "https://raw.githubusercontent.com/mrbvrz/segoe-ui-linux/master/install.sh" \
        -O "$FONT_TMP/install.sh"
    chmod +x "$FONT_TMP/install.sh"
    bash "$FONT_TMP/install.sh"
    echo "   ✔ Segoe UI installed."
fi

# ─── Extensions ──────────────────────────────────────────────────────────────
echo "📁 Restoring extensions..."
if [ -d "$BACKUP_DIR/extensions" ]; then
    mkdir -p "$HOME/.local/share/gnome-shell/extensions"
    cp -r "$BACKUP_DIR/extensions/." "$HOME/.local/share/gnome-shell/extensions/"
else
    echo "⚠️  No extensions backup found, skipping."
fi

# ─── Themes & Icons ──────────────────────────────────────────────────────────
echo "🎨 Restoring themes..."
[ -d "$BACKUP_DIR/themes" ] && cp -r "$BACKUP_DIR/themes" "$HOME/.themes"

echo "🖼️  Restoring icons..."
[ -d "$BACKUP_DIR/icons" ] && cp -r "$BACKUP_DIR/icons" "$HOME/.icons"

# ─── dconf settings ──────────────────────────────────────────────────────────
echo "💾 Restoring GNOME appearance settings..."
dconf load /org/gnome/shell/extensions/ < "$BACKUP_DIR/extensions-settings.ini"
dconf load /org/gnome/desktop/interface/ < "$BACKUP_DIR/interface.ini"
dconf load /org/gnome/desktop/wm/preferences/ < "$BACKUP_DIR/wm-preferences.ini"

# ─── Re-enable extensions ────────────────────────────────────────────────────
echo "🧩 Re-enabling extensions..."
while IFS= read -r ext; do
    gnome-extensions enable "$ext" 2>/dev/null \
        && echo "   ✔ $ext" \
        || echo "   ⚠️  Could not enable: $ext"
done < "$BACKUP_DIR/extensions.txt"

# ─── Restart GNOME Shell ─────────────────────────────────────────────────────
echo "🔄 Restarting GNOME Shell..."
killall -3 gnome-shell 2>/dev/null \
    || echo "⚠️  Log out and back in to apply changes."

echo "✅ UI restore complete!"
