# dotfiles

Black editorial Hyprland setup: Lua-based Hyprland config, a Quickshell
bar/panel suite, and a matching kitty theme. Everything is monochrome
(`#070707` / cream / amber) with JetBrains Mono and zero rounding.

## What's inside

| Path | Purpose |
| --- | --- |
| `.config/hypr/` | Hyprland entry point plus Lua modules (colors, monitors, binds, rules, autostart) |
| `.config/quickshell/` | Bar, audio/clipboard/launcher/media/calendar/system panels, OSD, notifications |
| `.config/kitty/` | kitty theme matching the panel palette |
| `.config/qt5ct`, `.config/qt6ct`, `.config/kdeglobals` | Qt/KDE dark theme |
| `.local/bin/hypr-binds-gen` | Generates `~/.cache/quickshell/keybinds.json` from `keybinds.lua` |
| `.local/bin/theme-sync` | Mirrors `modules/colors.lua` into Quickshell's `Theme.qml` |
| `.fonts/` | Roboto (used by a few Qt apps) |
| `Pictures/Wallpapers/courtyard.jpg` | Default wallpaper |

## Install

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh              # copy configs (backs up existing files)
./install.sh --packages   # also install Arch packages with pacman
```

Existing files are moved to `~/.dotfiles-backup-<timestamp>` first.
Then log out and start Hyprland.

`~/.local/bin` is added to `PATH` by the installed `.bashrc`; the Hyprland
binds call the scripts by absolute path, so they work without it.

## Key pieces

- **Bar:** workspaces, window title/media, layout, `VOL`, network, Bluetooth,
  date and clock. Left-click volume opens the mixer, right-click mutes,
  scroll changes volume.
- **Audio panel:** per-device volume bars (click/drag/scroll), MUTE per row,
  click a row to make it the default output/input.
- **Clipboard history:** `cliphist` + the clipboard panel; Super+V.
- **Screenshots:** `Print` region, `Super+Print` output, `Super+Shift+Print`
  window. Files land in `~/Pictures/Screenshots` and are placed on **both**
  clipboards: `wl-copy` for native Wayland apps and a small X11 selection
  owner for XWayland apps. `~/.local/bin/take-screenshot` does the capture,
  `copy-image` publishes it.
- **Palette:** edit `~/.config/hypr/modules/colors.lua`, then run
  `theme-sync` to regenerate `core/Theme.qml`. Binds metadata lives in
  `modules/keybinds.lua`; `hypr-binds-gen` refreshes the cheatsheet.

Default monitor is `DP-3` at 1920x1080@165 in `modules/monitors.lua`; change
it for your hardware. The `hyprpaper.conf` path is rewritten to `$HOME` by
`install.sh`.

## Requirements

Arch Linux with Hyprland 0.5x, Quickshell 0.3.x, PipeWire/WirePlumber, and the
packages listed in `install.sh` (`--packages` installs them).
