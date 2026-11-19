import QtQuick
import Quickshell
import "../core"

// Full-screen power menu: 3x2 grid, hover = cream, destructive = confirm.
Item {
    id: root

    property string confirming: ""

    function reset() {
        confirming = "";
    }

    function activate(label) {
        if (label === "CANCEL") {
            UiState.close();
            return;
        }

        var destructive = label === "LOGOUT" || label === "REBOOT" || label === "SHUTDOWN";
        if (destructive && confirming !== label) {
            confirming = label;
            return;
        }

        confirming = "";
        if (label === "LOCK")
            Quickshell.execDetached(["hyprlock"]);
        else if (label === "SUSPEND")
            Quickshell.execDetached(["systemctl", "suspend"]);
        else if (label === "LOGOUT")
            Quickshell.execDetached(["hyprctl", "dispatch", "exit"]);
        else if (label === "REBOOT")
            Quickshell.execDetached(["systemctl", "reboot"]);
        else if (label === "SHUTDOWN")
            Quickshell.execDetached(["systemctl", "poweroff"]);

        UiState.close();
    }

    onVisibleChanged: {
        if (!visible)
            reset();
    }

    Grid {
        anchors.centerIn: parent
        columns: 3
        spacing: 1

        Repeater {
            model: ["LOCK", "SUSPEND", "LOGOUT", "REBOOT", "SHUTDOWN", "CANCEL"]

            delegate: Rectangle {
                id: cell
                required property string modelData

                width: 200
                height: 120
                color: cellMouse.containsMouse ? Theme.cream : Theme.bg0
                border.width: 1
                border.color: Theme.line

                Behavior on color {
                    ColorAnimation { duration: 90; easing.type: Easing.OutCubic }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.confirming === cell.modelData ? "CONFIRM?" : cell.modelData
                    color: cellMouse.containsMouse ? Theme.bg0 : (cell.modelData === "CANCEL" ? Theme.inkDim : Theme.ink)
                    font.family: Theme.mono
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    font.letterSpacing: 1.8
                }

                MouseArea {
                    id: cellMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activate(cell.modelData)
                }
            }
        }
    }
}
