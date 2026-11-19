import QtQuick
import "../core"

// Hairline volume bar with drag, click and scroll.
Item {
    id: root

    property var node
    property color fillColor: Theme.cream
    property bool interactive: true

    readonly property real value: node && node.audio ? Math.max(0, Math.min(1, node.audio.volume)) : 0
    readonly property bool muted: node && node.audio ? node.audio.muted : false

    implicitHeight: 14

    function setFromX(x) {
        if (!interactive || !node || !node.audio)
            return;
        Audio.setVolume(node, x / width);
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 4
        color: Theme.line
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width * root.value
        height: 4
        color: root.muted ? Theme.lineStrong : root.fillColor
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
        onClicked: function (mouse) { root.setFromX(mouse.x); }
        onPositionChanged: function (mouse) { if (pressed) root.setFromX(mouse.x); }
    }

    WheelHandler {
        enabled: root.interactive
        onWheel: function (event) {
            Audio.nudge(root.node, event.angleDelta.y > 0 ? 5 : -5);
        }
    }
}
