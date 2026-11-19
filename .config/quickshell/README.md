# Quickshell shell

Panel-block desktop for Hyprland: black editorial surfaces, hairline rules,
cream inverted blocks, and one amber accent reserved for "live" states.

The shell is a single Quickshell config (`shell.qml`) with a 30px top bar,
one shared panel surface, a notification stack, and a volume OSD.

## Runtime

- Quickshell 0.3.2, Hyprland 0.57.x (Lua config), PipeWire, NetworkManager,
  BlueZ, MPRIS, `cliphist`, `hyprpaper`.
- Start manually: `qs -n -d`
- Restart after edits: `qs kill && qs -n -d` (Quickshell also hot-reloads).
- Logs: `journalctl --user -u quickshell` if launched by systemd, otherwise
  stderr from `qs -n -d`. Quickshell also writes
  `/run/user/$UID/quickshell/by-id/*/log.qslog`.

## Files

```
~/.config/quickshell/
├── shell.qml                 # ShellRoot + IPC handler (target "shell")
├── core/                     # singletons (qmldir)
│   ├── Theme.qml             # GENERATED — do not edit
│   ├── UiState.qml           # open panel, DND, unread count
│   ├── Audio.qml             # PipeWire sinks/sources/streams + OSD state
│   ├── Media.qml             # MPRIS player
│   ├── Keybinds.qml          # watches keybinds.lua and the generated JSON
│   ├── Clipboard.qml         # cliphist list/delete/wipe/copy
│   ├── Launcher.qml          # desktop entries
│   ├── Notifs.qml            # NotificationServer + history/DND
│   └── Wallpapers.qml        # folder listing + hyprpaper IPC
└── components/               # bar, panels, frame, notification stack, OSD
```

Hyprland:

```
~/.config/hypr/hyprland.lua   # requires modules in a fixed order
~/.config/hypr/modules/
├── colors.lua                # palette source of truth
├── monitors.lua              # DP-3 + preferred fallback
├── general.lua               # gaps 8/12, border 1, dwindle
├── decoration.lua            # rounding 2, no shadow/blur, opaque
├── animations.lua            # 120/160/90ms fades
├── input.lua                 # us,ru + grp:alt_shift_toggle
├── keybinds.lua              # b() metadata + binds
├── rules.lua                 # floating / XWayland fixes
├── permissions.lua           # grim + portal screencopy
└── autostart.lua             # hyprpaper, quickshell, cliphist, polkit
```

## Palette

| Token | Hex | Use |
| - | - | - |
| `bg0` | `#070707` | bar, panels, cards |
| `bg1` | `#0E0E0D` | rows, fields |
| `bg2` | `#171716` | hover |
| `line` | `#2A2A27` | hairlines |
| `lineStrong` | `#3D3D38` | focus, strong edges |
| `ink` | `#EDE9DF` | primary text |
| `inkDim` | `#8F8D84` | micro labels |
| `cream` | `#E9E3D5` | inverted blocks, active states |
| `amber` | `#D98A3F` | mic live, critical, recording only |

Type is JetBrains Mono everywhere. Bar/panels are 0 radius; windows are 2px.
No shadows, blur, transparency, or extra colors.

### Changing colors

1. Edit `~/.config/hypr/modules/colors.lua`.
2. Run `~/.local/bin/theme-sync`.
3. Reload Quickshell (`qs kill && qs -n -d`).

`Theme.qml` is generated from the Lua palette so the bar and window borders
cannot drift.

## Bar

30px, full width, opaque `bg0`, 1px bottom hairline.

- **Left:** workspaces 1–0 in 22×18 cells; active = cream block with black
  number; occupied = cream text; empty = dim.
- **Center:** active window title in 9px uppercase. While media is playing it
  becomes `▶ TITLE — ARTIST` and clicking opens the media panel.
- **Right:** `US`/`RU` layout chip, volume (mute shows `MUTE` in amber),
  `ETH`/`NET` with four bars, `BT`, notification marker, date, clock.
- Click volume → audio panel; right-click volume → mute; scroll volume →
  volume; click clock/date → calendar; click `NET`/`BT` → system panel.

The layout chip polls `hyprctl devices -j` once per second. Everything else
comes from Quickshell signals.

## Panels and IPC

Only one panel opens at a time. `Esc`, click-outside, or the `ESC` label closes
it. All commands target `shell`:

```
qs ipc call shell launcher
qs ipc call shell keybinds
qs ipc call shell clipboard
qs ipc call shell audio
qs ipc call shell notifications
qs ipc call shell wallpaper
qs ipc call shell calendar
qs ipc call shell system
qs ipc call shell media
qs ipc call shell power
qs ipc call shell dnd true
qs ipc call shell close
```

Sizes follow the plan: audio 400×520 (top-right), keybinds 960×620 (center),
launcher 640×460 (center), clipboard 560×480 (center), calendar 380×420
(top-right), system 420×560 (top-right), wallpaper 720×520 (center), media
380×240 (top-right), power full-screen with a 72% black scrim and a 3×2 grid,
notifications 380 wide, OSD 280×72 bottom-center.

### Audio

Outputs, inputs and application streams come from PipeWire. Clicking a device
sets the default through `wpctl set-default`; `MUTE` toggles the node; scrolling
or dragging the hairline changes volume. The amber dot marks an unmuted
default source. Any sink volume/mute change shows the OSD.

### Keybinds

`modules/keybinds.lua` is the single source. Every bind is one `b(...)` line:

```lua
b("SUPER + K", "SYSTEM", "Keybind cheatsheet", hl.dsp.exec_cmd("qs ipc call shell keybinds"))
```

`~/.local/bin/hypr-binds-gen` parses those calls into
`~/.cache/quickshell/keybinds.json`. Quickshell runs the generator at startup
and watches both files, so saving the Lua file regenerates the JSON. To
regenerate manually:

```
~/.local/bin/hypr-binds-gen
hyprctl reload
```

Categories: `LAUNCH`, `WINDOWS`, `WORKSPACES`, `SYSTEM`, `MEDIA`, `SCREENSHOT`.
The viewer supports live search, arrow navigation, and Enter to run the bind.
Footer shows generation time and bind count.

### Clipboard

`cliphist` + `wl-clipboard`. Watchers run at login from `autostart.lua`:

```
wl-paste --type text  --watch cliphist store
wl-paste --type image --watch cliphist store
```

`Super+V` opens searchable history. Enter copies, Delete removes, Ctrl+Delete
wipes. Image rows show dimensions and size; text rows show the first line.
The source application is not exposed by cliphist, so the row type is shown
instead (`TEXT` / `IMAGE`).

### Notifications

Quickshell owns `org.freedesktop.Notifications`. **Do not run dunst**: two
servers cannot own the name. Popups stack under the bar top-right; critical
notifications get a 2px amber left edge and amber timeout line. History and
DND live in `Super+N`. `notify-send` works out of the box.

### Wallpaper

Images are read from `~/Pictures/Wallpapers`. Applying a thumbnail runs:

```
hyprctl hyprpaper wallpaper "DP-3,/path/to/image,cover"
```

`hyprpaper.conf` uses the 0.8+ `wallpaper { monitor/path/fit_mode }` syntax.

### Screenshots

`hyprshot` writes to `~/Pictures/Screenshots` and copies to the clipboard:

- `Print` — region (interactive `slurp`)
- `Super+Print` — active output
- `Super+Shift+Print` — active window

### Power

`Super+P` opens the full-screen menu. Destructive entries (`LOGOUT`, `REBOOT`,
`SHUTDOWN`) require a second click and show `CONFIRM?`. `LOCK` runs `hyprlock`.

## Binds

| Key | Action |
| - | - |
| `Super+Q` | kitty |
| `Super+E` | Dolphin |
| `Super+R` | launcher |
| `Super+V` | clipboard |
| `Super+K` | keybinds |
| `Super+A` | audio |
| `Super+N` | notifications / DND |
| `Super+W` | wallpaper |
| `Super+P` | power |
| `Super+C` | close window |
| `Super+J` | toggle split |
| `Super+Shift+V` | toggle floating |
| `Super+Shift+F` | fullscreen |
| `Super+arrows` | focus |
| `Super+Shift+arrows` | move window |
| `Super+1…0` | workspace |
| `Super+Shift+1…0` | move to workspace |
| `Super+S` / `Super+Shift+S` | scratchpad toggle / move |
| `Print` / `Super+Print` / `Super+Shift+Print` | region / output / window screenshot |
| `Super+L` / `Super+Alt+L` | lock |
| `XF86Audio*` | volume / mute / mic mute / media |
| `Super+drag` / `Super+right-drag` | move / resize |
| `Super+scroll` | switch workspaces |

`Alt+Shift` toggles US ↔ RU. Standard ЙЦУКЕН, CapsLock unchanged.

## Troubleshooting

- **No bar:** `qs -n -d`, then check stderr. `qs list` shows instances.
- **Panel won't open:** `qs ipc call shell <panel>` and inspect logs for QML
  errors; a failed Loader leaves the transparent overlay empty.
- **No notifications:** something else owns `org.freedesktop.Notifications`.
  `pkill dunst` (and remove it from any old autostart).
- **No clipboard rows:** the `wl-paste` watchers are not running. Start them
  from `autostart.lua` or manually.
- **Wallpaper did not change:** confirm `hyprpaper` is running and
  `hyprctl hyprpaper listactive` reports `DP-3: <path>`.
- **`grim` hangs / empty screenshots:** screencopy permissions. The current
  config keeps `ecosystem.enforce_permissions = false` because enforcement
  caused `grim` to hang in this session; `permissions.lua` still contains the
  allow entries for when enforcement is enabled.

## Notes / known gaps

- hyprlock config: `~/.config/hypr/hyprlock.conf` (black screen, 96px cream
  clock, hairline password underline). **Not verified:** launching hyprlock in
  this session crashed and left Hyprland on its death screen, so lock testing
  was stopped. The binds and power-menu entry remain per the plan; do not
  launch it until the PAM/session mismatch is resolved.
- Media controls are wired to MPRIS and were verified against a minimal MPRIS
  test player (title, artist, progress, prev/play/next, bar line). Real
  application playback was not exercised.
- Font size in terminal/notification body is tuned for 1080p; adjust
  `font.pixelSize` values if you change scale.
