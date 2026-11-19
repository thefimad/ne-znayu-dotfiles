pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Wallpaper folder + apply via hyprpaper's IPC.
QtObject {
    id: root

    readonly property string folder: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property var files: []

    property Process listProcess: Process {
        command: ["bash", "-c",
            "find \"$HOME/Pictures/Wallpapers\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -printf '%f\\n' | sort"]
        stdout: StdioCollector {
            onStreamFinished: {
                var names = String(text || "").split("\n");
                var result = [];
                for (var i = 0; i < names.length; i++) {
                    if (names[i].length)
                        result.push(root.folder + "/" + names[i]);
                }
                root.files = result;
            }
        }
    }

    Component.onCompleted: refresh()

    function refresh() {
        if (!listProcess.running)
            listProcess.running = true;
    }

    function monitorName() {
        return Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "DP-3";
    }

    function apply(path) {
        if (!path)
            return;
        Quickshell.execDetached(["hyprctl", "hyprpaper", "wallpaper",
            monitorName() + "," + path + ",cover"]);
    }
}
