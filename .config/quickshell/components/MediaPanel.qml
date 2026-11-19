import QtQuick
import "../core"

// Player card: no album art, hairline progress, mono times.
Item {
    id: root

    readonly property real progress: {
        Media.tick;
        return Media.length > 0 ? Math.max(0, Math.min(1, Media.position / Media.length)) : 0;
    }

    readonly property string elapsed: {
        Media.tick;
        return Media.format(Media.position);
    }

    readonly property string total: {
        Media.tick;
        return Media.format(Media.length);
    }

    PanelFrame {
        anchors.fill: parent
        title: "MEDIA"
        hint: Media.active ? "CLICK CONTROLS TO PLAY · PAUSE · SKIP" : "NO PLAYER SELECTED"
        footerRight: Media.identity

        Item {
            anchors.fill: parent
            anchors.margins: 16

            Column {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 4

                Text {
                    text: Media.title.length ? Media.title.toUpperCase() : "NO PLAYER"
                    color: Theme.ink
                    elide: Text.ElideRight
                    width: parent.width
                    font.family: Theme.mono
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.letterSpacing: 0.4
                }

                Text {
                    text: Media.artist.length ? Media.artist.toUpperCase() : Media.identity.toUpperCase()
                    color: Theme.inkDim
                    elide: Text.ElideRight
                    width: parent.width
                    font.family: Theme.mono
                    font.pixelSize: 9
                    font.letterSpacing: 1.2
                }
            }

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 42
                height: 18

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 1
                    color: Theme.line
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * root.progress
                    height: 1
                    color: Theme.cream
                }

                Text {
                    anchors.left: parent.left
                    anchors.top: parent.bottom
                    anchors.topMargin: 4
                    text: root.elapsed
                    color: Theme.inkDim
                    font.family: Theme.mono
                    font.pixelSize: 8
                }

                Text {
                    anchors.right: parent.right
                    anchors.top: parent.bottom
                    anchors.topMargin: 4
                    text: root.total
                    color: Theme.inkDim
                    font.family: Theme.mono
                    font.pixelSize: 8
                }
            }

            Row {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                spacing: 22

                Repeater {
                    model: [
                        { label: "PREV", action: "prev" },
                        { label: Media.playing ? "PAUSE" : "PLAY", action: "toggle" },
                        { label: "NEXT", action: "next" }
                    ]
                    delegate: Item {
                        required property var modelData
                        width: controlText.implicitWidth
                        height: 18

                        Text {
                            id: controlText
                            anchors.centerIn: parent
                            text: modelData.label
                            color: controlMouse.containsMouse ? Theme.cream : Theme.inkDim
                            font.family: Theme.mono
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1.2
                        }

                        MouseArea {
                            id: controlMouse
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.action === "prev")
                                    Media.previous();
                                else if (modelData.action === "next")
                                    Media.next();
                                else
                                    Media.toggle();
                            }
                        }
                    }
                }
            }
        }
    }
}
