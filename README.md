# 🖥️ gnome-ui-backup

> Backup and restore your GNOME desktop look — extensions, themes, icons, and fonts — across any supported Linux distro.

---

## ✨ What it does

These two scripts let you clone your exact GNOME visual setup to a new machine or fresh install — without touching your apps or packages.

| What gets saved | What gets skipped |
|---|---|
| ✅ GNOME Shell extensions | ❌ Installed applications |
| ✅ Extension settings (dconf) | ❌ System packages |
| ✅ Themes | ❌ App configs |
| ✅ Icon packs | |
| ✅ Interface & WM preferences | |
| ✅ Segoe UI font | |

---

## 🐧 Supported distros

| Distro family | Includes |
|---|---|
| **Arch** | Arch, Manjaro, EndeavourOS, Garuda |
| **Debian/Ubuntu** | Ubuntu, Debian, Pop!\_OS, Mint, Elementary |
| **Fedora** | Fedora |
| **openSUSE** | openSUSE Leap / Tumbleweed |

> **Cross-distro restore** is supported. If you back up on Arch and restore on Ubuntu, the scripts will warn you and still apply themes, icons, extensions and fonts correctly.

---

## 🚀 Usage

### 1. Backup

Run this on your **source machine**:

```bash
chmod +x gnome-backup.sh
./gnome-backup.sh
```

This creates a `~/gnome-ui-backup/` folder with everything needed.

### 2. Copy to new machine

Transfer the backup folder however you like:

```bash
# Example with rsync
rsync -av ~/gnome-ui-backup/ user@newmachine:~/gnome-ui-backup/

# Or with scp
scp -r ~/gnome-ui-backup/ user@newmachine:~/
```

### 3. Restore

Run this on your **target machine**:

```bash
chmod +x restore-gnome.sh
./restore-gnome.sh
```

The restore script will automatically:
- Detect your distro and use the right package manager
- Install **GNOME Tweaks** if not already present
- Download and install the **Segoe UI** font if missing
- Restore all extensions, themes, icons, and dconf settings
- Re-enable each extension
- Restart GNOME Shell

---

## 📦 What gets installed automatically

### GNOME Tweaks
Used to apply themes and fonts. Installed via your distro's package manager if not found.

### Segoe UI font
Installed from [mrbvrz/segoe-ui-linux](https://github.com/mrbvrz/segoe-ui-linux) if not already present on the system. Includes the full font family with emoji and symbol support.

---

## 📁 Backup folder structure

```
~/gnome-ui-backup/
├── distro.txt                  # Source distro ID
├── pkg_manager.txt             # Package manager used
├── extensions.txt              # List of enabled extensions
├── extensions/                 # Extension files
├── extensions-settings.ini     # dconf extension settings
├── interface.ini               # dconf interface settings
├── wm-preferences.ini          # dconf window manager settings
├── themes/                     # ~/.themes
└── icons/                      # ~/.icons
```

---

## ⚠️ Notes

- The scripts only back up **user-level** themes and icons (`~/.themes`, `~/.icons`). System-wide themes in `/usr/share/themes` are not included.
- If an extension can't be re-enabled during restore (e.g. incompatible GNOME Shell version), it will warn you and continue.
- If GNOME Shell can't be restarted automatically, just **log out and back in** — all changes will apply.

---

## 📄 License

MIT
