import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "components"
import "core"

ShellRoot {
    // Force the keybind watcher to exist from startup so edits to
    // keybinds.lua regenerate the JSON even before the panel is first opened.
    property int keybindCount: Keybinds.count

    Bar {}
    Overlay {}
    NotificationStack {}
    VolumeOsd {}

    IpcHandler {
        target: "shell"

        function open(panel: string): void { UiState.open(panel); }
        function toggle(panel: string): void { UiState.toggle(panel); }
        function close(): void { UiState.close(); }

        function launcher(): void { UiState.toggle("launcher"); }
        function keybinds(): void { UiState.toggle("keybinds"); }
        function clipboard(): void { UiState.toggle("clipboard"); }
        function audio(): void { UiState.toggle("audio"); }
        function notifications(): void { UiState.toggle("notifications"); }
        function wallpaper(): void { UiState.toggle("wallpaper"); }
        function calendar(): void { UiState.toggle("calendar"); }
        function system(): void { UiState.toggle("system"); }
        function media(): void { UiState.toggle("media"); }
        function power(): void { UiState.toggle("power"); }

        function dnd(value: bool): void { Notifs.setDnd(value); }
        function lock(): void { Quickshell.execDetached(["hyprlock"]); }

        function version(): string { return "1.0"; }

    }
}
