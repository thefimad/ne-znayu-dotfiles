import QtQuick
import "../core"

// One device or stream row: default marker, labels, mute, hairline volume.
Item {
    id: root

    property var node
    property bool selected: false
    property bool isSource: false
    property bool canDefault: true

    width: parent ? parent.width : 0
    height: 56

    Rectangle {
        anchors.fill: parent
        color: rowMouse.containsMouse ? Theme.bg1 : "transparent"
    }

    // Row-wide click target for "set as default". Declared before the volume
    // bar and mute control so those receive their own clicks.
    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.canDefault
        cursorShape: root.canDefault ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (!root.canDefault)
                return;
            if (root.isSource)
                Audio.setDefaultSource(root.node);
            else
                Audio.setDefaultSink(root.node);
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        height: 10
        color: root.selected ? Theme.cream : "transparent"
        border.width: root.selected ? 0 : 1
        border.color: Theme.lineStrong

        Text {
            anchors.centerIn: parent
            visible: root.selected
            text: "•"
            color: Theme.bg0
            font.family: Theme.mono
            font.pixelSize: 9
        }
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 34
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Row {
            spacing: 6
            Text {
                text: (root.node && root.node.isStream
                    ? Audio.streamLabel(root.node)
                    : Audio.label(root.node)).toUpperCase()
                color: Theme.ink
                elide: Text.ElideRight
                width: Math.min(implicitWidth, root.width - 108)
                font.family: Theme.mono
                font.pixelSize: 11
                font.weight: Font.Medium
                font.letterSpacing: 0.3
            }
            Text {
                visible: root.isSource && root.node === Audio.source && !Audio.muted
                text: "●"
                color: Theme.amber
                font.pixelSize: 8
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        VolumeBar {
            width: root.width - 48
            node: root.node
        }
    }

    Item {
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        width: 48
        height: 24

        Text {
            anchors.centerIn: parent
            text: root.node && root.node.audio && root.node.audio.muted ? "MUTED" : "MUTE"
            color: root.node && root.node.audio && root.node.audio.muted ? Theme.amber : Theme.inkDim
            font.family: Theme.mono
            font.pixelSize: 8
            font.letterSpacing: 1.0
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Audio.toggleMute(root.node)
        }
    }

    WheelHandler {
        onWheel: function (event) {
            Audio.nudge(root.node, event.angleDelta.y > 0 ? 5 : -5);
        }
    }
}
