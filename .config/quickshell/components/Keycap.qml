import QtQuick
import "../core"

// 1px outlined keycap, cream text, never filled.
Rectangle {
    id: root

    property string label: ""
    property bool inverted: false

    implicitWidth: text.implicitWidth + 12
    implicitHeight: 20
    color: "transparent"
    border.width: 1
    border.color: root.inverted ? Theme.bg0 : Theme.lineStrong
    radius: 0

    Text {
        id: text
        anchors.centerIn: parent
        text: root.label
        color: root.inverted ? Theme.bg0 : Theme.cream
        font.family: Theme.mono
        font.pixelSize: 9
        font.weight: Font.DemiBold
        font.letterSpacing: 0.8
    }
}
