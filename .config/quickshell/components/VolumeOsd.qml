import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"

// Volume OSD, bottom-center, 280x72.
PanelWindow {
    id: root

    anchors.bottom: true
    anchors.left: true
    margins.bottom: 48
    margins.left: Math.round((screen.width - 280) / 2)
    implicitWidth: 280
    implicitHeight: 72
    color: "transparent"
    focusable: false
    visible: Audio.osdVisible

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        color: Theme.bg0
        border.width: 1
        border.color: Theme.line

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.topMargin: 4
            text: Audio.osdMuted ? "MUTED" : (Audio.osdValue + "%")
            color: Audio.osdMuted ? Theme.amber : Theme.cream
            font.family: Theme.mono
            font.pixelSize: Audio.osdMuted ? 28 : 36
            font.weight: Font.ExtraBold
            font.letterSpacing: -1
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12
            text: Audio.osdTitle.toUpperCase()
            color: Theme.inkDim
            elide: Text.ElideRight
            width: parent.width - 32
            font.family: Theme.mono
            font.pixelSize: 8
            font.letterSpacing: 1.1
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 4
            color: Theme.line

            Rectangle {
                height: parent.height
                width: parent.width * (Audio.osdMuted ? 0 : Audio.osdValue / 100)
                color: Theme.cream
            }
        }
    }
}
