import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"

// One full-screen transparent surface hosts every panel. Clicking the scrim
// (or pressing Esc) closes it; panels are opaque and swallow their own clicks.
PanelWindow {
    id: overlay

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: overlay.current === "power" ? Qt.rgba(0, 0, 0, 0.72) : "transparent"
    visible: UiState.panel !== ""
    focusable: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-overlay"
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property string current: UiState.panel
    readonly property bool centered: current === "keybinds" || current === "launcher" || current === "clipboard" || current === "wallpaper"


    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        onActivated: UiState.close()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: UiState.close()
    }

    Loader {
        id: slot

        readonly property int panelWidth: {
            switch (overlay.current) {
            case "audio": return 400;
            case "keybinds": return 960;
            case "launcher": return 640;
            case "clipboard": return 560;
            case "calendar": return 380;
            case "system": return 420;
            case "wallpaper": return 720;
            case "media": return 380;
            case "notifications": return 380;
            case "power": return overlay.width;
            default: return 400;
            }
        }

        readonly property int panelHeight: {
            switch (overlay.current) {
            case "audio": return 520;
            case "keybinds": return 620;
            case "launcher": return 460;
            case "clipboard": return 480;
            case "calendar": return 420;
            case "system": return 560;
            case "wallpaper": return 520;
            case "media": return 240;
            case "notifications": return 420;
            case "power": return overlay.height;
            default: return 520;
            }
        }

        width: panelWidth
        height: panelHeight
        x: overlay.current === "power" ? 0 : (overlay.centered ? (overlay.width - width) / 2 : overlay.width - width - 12)
        y: overlay.current === "power" ? 0 : (overlay.centered ? (overlay.height - height) / 2 : 38)

        sourceComponent: {
            switch (overlay.current) {
            case "audio": return audioPanel;
            case "keybinds": return keybindsPanel;
            case "launcher": return launcherPanel;
            case "clipboard": return clipboardPanel;
            case "calendar": return calendarPanel;
            case "system": return systemPanel;
            case "wallpaper": return wallpaperPanel;
            case "media": return mediaPanel;
            case "notifications": return notificationsPanel;
            case "power": return powerPanel;
            default: return null;
            }
        }

        opacity: overlay.current === "" ? 0 : 1
        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }

    Component { id: audioPanel; AudioPanel {} }
    Component { id: keybindsPanel; KeybindsPanel {} }
    Component { id: launcherPanel; LauncherPanel {} }
    Component { id: clipboardPanel; ClipboardPanel {} }
    Component { id: calendarPanel; CalendarPanel {} }
    Component { id: systemPanel; SystemPanel {} }
    Component { id: wallpaperPanel; WallpaperPanel {} }
    Component { id: mediaPanel; MediaPanel {} }
    Component { id: notificationsPanel; NotificationsPanel {} }
    Component { id: powerPanel; PowerMenu {} }
}
