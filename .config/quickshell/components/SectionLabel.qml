import QtQuick
import "../core"

// Micro section heading inside a panel.
Item {
    id: root
    property string label: ""
    height: 26
    width: parent ? parent.width : 0

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 7
        text: root.label.toUpperCase()
        color: Theme.inkDim
        font.family: Theme.mono
        font.pixelSize: 9
        font.letterSpacing: 1.2
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.line
    }
}
