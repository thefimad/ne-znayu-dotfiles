-- Metadata-aware binds.
-- b(key, category, description, dispatcher, opts?)
-- Parsed by ~/.local/bin/hypr-binds-gen -> ~/.cache/quickshell/keybinds.json
-- Keep every b(...) call on a single line.

local mainMod = "SUPER"
local shot = os.getenv("HOME") .. "/.local/bin/take-screenshot "

local function b(key, category, description, dispatcher, opts)
    return hl.bind(key, dispatcher, opts)
end

---------------------------------
---- LAUNCH ---------------------
---------------------------------

b("SUPER + Q", "LAUNCH", "Terminal (kitty)", hl.dsp.exec_cmd("kitty"))
b("SUPER + E", "LAUNCH", "File manager (Dolphin)", hl.dsp.exec_cmd("dolphin"))
b("SUPER + R", "LAUNCH", "Application launcher", hl.dsp.exec_cmd("qs ipc call shell launcher"))
b("SUPER + V", "LAUNCH", "Clipboard history", hl.dsp.exec_cmd("qs ipc call shell clipboard"))
b("SUPER + K", "LAUNCH", "Keybind cheatsheet", hl.dsp.exec_cmd("qs ipc call shell keybinds"))
b("SUPER + A", "LAUNCH", "Audio mixer", hl.dsp.exec_cmd("qs ipc call shell audio"))
b("SUPER + N", "LAUNCH", "Notifications / do not disturb", hl.dsp.exec_cmd("qs ipc call shell notifications"))
b("SUPER + W", "LAUNCH", "Wallpaper picker", hl.dsp.exec_cmd("qs ipc call shell wallpaper"))

---------------------------------
---- WINDOWS --------------------
---------------------------------

b("SUPER + C", "WINDOWS", "Close active window", hl.dsp.window.close())
b("SUPER + J", "WINDOWS", "Toggle split direction (dwindle)", hl.dsp.layout("togglesplit"))
b("SUPER + SHIFT + V", "WINDOWS", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
b("SUPER + SHIFT + F", "WINDOWS", "Toggle fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

b("SUPER + left", "WINDOWS", "Focus left", hl.dsp.focus({ direction = "left" }))
b("SUPER + right", "WINDOWS", "Focus right", hl.dsp.focus({ direction = "right" }))
b("SUPER + up", "WINDOWS", "Focus up", hl.dsp.focus({ direction = "up" }))
b("SUPER + down", "WINDOWS", "Focus down", hl.dsp.focus({ direction = "down" }))

b("SUPER + SHIFT + left", "WINDOWS", "Move window left", hl.dsp.window.move({ direction = "left" }))
b("SUPER + SHIFT + right", "WINDOWS", "Move window right", hl.dsp.window.move({ direction = "right" }))
b("SUPER + SHIFT + up", "WINDOWS", "Move window up", hl.dsp.window.move({ direction = "up" }))
b("SUPER + SHIFT + down", "WINDOWS", "Move window down", hl.dsp.window.move({ direction = "down" }))

---------------------------------
---- WORKSPACES -----------------
---------------------------------

b("SUPER + 1", "WORKSPACES", "Workspace 1", hl.dsp.focus({ workspace = 1 }))
b("SUPER + 2", "WORKSPACES", "Workspace 2", hl.dsp.focus({ workspace = 2 }))
b("SUPER + 3", "WORKSPACES", "Workspace 3", hl.dsp.focus({ workspace = 3 }))
b("SUPER + 4", "WORKSPACES", "Workspace 4", hl.dsp.focus({ workspace = 4 }))
b("SUPER + 5", "WORKSPACES", "Workspace 5", hl.dsp.focus({ workspace = 5 }))
b("SUPER + 6", "WORKSPACES", "Workspace 6", hl.dsp.focus({ workspace = 6 }))
b("SUPER + 7", "WORKSPACES", "Workspace 7", hl.dsp.focus({ workspace = 7 }))
b("SUPER + 8", "WORKSPACES", "Workspace 8", hl.dsp.focus({ workspace = 8 }))
b("SUPER + 9", "WORKSPACES", "Workspace 9", hl.dsp.focus({ workspace = 9 }))
b("SUPER + 0", "WORKSPACES", "Workspace 10", hl.dsp.focus({ workspace = 10 }))

b("SUPER + SHIFT + 1", "WORKSPACES", "Move window to workspace 1", hl.dsp.window.move({ workspace = 1 }))
b("SUPER + SHIFT + 2", "WORKSPACES", "Move window to workspace 2", hl.dsp.window.move({ workspace = 2 }))
b("SUPER + SHIFT + 3", "WORKSPACES", "Move window to workspace 3", hl.dsp.window.move({ workspace = 3 }))
b("SUPER + SHIFT + 4", "WORKSPACES", "Move window to workspace 4", hl.dsp.window.move({ workspace = 4 }))
b("SUPER + SHIFT + 5", "WORKSPACES", "Move window to workspace 5", hl.dsp.window.move({ workspace = 5 }))
b("SUPER + SHIFT + 6", "WORKSPACES", "Move window to workspace 6", hl.dsp.window.move({ workspace = 6 }))
b("SUPER + SHIFT + 7", "WORKSPACES", "Move window to workspace 7", hl.dsp.window.move({ workspace = 7 }))
b("SUPER + SHIFT + 8", "WORKSPACES", "Move window to workspace 8", hl.dsp.window.move({ workspace = 8 }))
b("SUPER + SHIFT + 9", "WORKSPACES", "Move window to workspace 9", hl.dsp.window.move({ workspace = 9 }))
b("SUPER + SHIFT + 0", "WORKSPACES", "Move window to workspace 10", hl.dsp.window.move({ workspace = 10 }))

b("SUPER + S", "WORKSPACES", "Toggle scratchpad", hl.dsp.workspace.toggle_special("magic"))
b("SUPER + SHIFT + S", "WORKSPACES", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:magic" }))
b("SUPER + mouse_down", "WORKSPACES", "Next workspace (scroll)", hl.dsp.focus({ workspace = "e+1" }))
b("SUPER + mouse_up", "WORKSPACES", "Previous workspace (scroll)", hl.dsp.focus({ workspace = "e-1" }))

---------------------------------
---- SYSTEM ---------------------
---------------------------------

b("SUPER + P", "SYSTEM", "Power menu", hl.dsp.exec_cmd("qs ipc call shell power"))
b("SUPER + L", "SYSTEM", "Lock screen", hl.dsp.exec_cmd("hyprlock"))
b("SUPER + ALT + L", "SYSTEM", "Lock screen", hl.dsp.exec_cmd("hyprlock"))

---------------------------------
---- MEDIA ----------------------
---------------------------------

b("XF86AudioRaiseVolume", "MEDIA", "Volume up", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+"), { locked = true, repeating = true })
b("XF86AudioLowerVolume", "MEDIA", "Volume down", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"), { locked = true, repeating = true })
b("XF86AudioMute", "MEDIA", "Mute output", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
b("XF86AudioMicMute", "MEDIA", "Mute microphone", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
b("XF86AudioPlay", "MEDIA", "Play / pause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
b("XF86AudioPause", "MEDIA", "Play / pause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
b("XF86AudioNext", "MEDIA", "Next track", hl.dsp.exec_cmd("playerctl next"), { locked = true })
b("XF86AudioPrev", "MEDIA", "Previous track", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

---------------------------------
---- SCREENSHOT -----------------
---------------------------------

b("Print", "SCREENSHOT", "Region to clipboard + file", hl.dsp.exec_cmd(shot .. "region"))
b("SUPER + Print", "SCREENSHOT", "Full output to clipboard + file", hl.dsp.exec_cmd(shot .. "output"))
b("SUPER + SHIFT + Print", "SCREENSHOT", "Active window to clipboard + file", hl.dsp.exec_cmd(shot .. "window"))

---------------------------------
---- MOUSE (not in cheatsheet) --
---------------------------------

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
