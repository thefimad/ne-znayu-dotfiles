-- Session processes. Runs once at Hyprland start (not on reload).
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("quickshell -n -d")
    hl.exec_cmd("sh -c 'wl-paste --type text --watch cliphist store'")
    hl.exec_cmd("sh -c 'wl-paste --type image --watch cliphist store'")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
    hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"')
end)
