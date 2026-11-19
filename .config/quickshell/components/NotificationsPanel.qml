import QtQuick
import "../core"

// Notification history + DND.
Item {
    id: root

    PanelFrame {
        anchors.fill: parent
        title: "NOTIFICATIONS"
        hint: "CLICK A ROW TO REMOVE · ESC CLOSE"
        footerRight: Notifs.history.length + " SAVED"

        Item {
            id: dndRow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 38

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "DO NOT DISTURB"
                color: UiState.dnd ? Theme.cream : Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 9
                font.letterSpacing: 1.2
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: UiState.dnd ? "ON" : "OFF"
                color: UiState.dnd ? Theme.amber : Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 9
                font.letterSpacing: 1.2
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifs.setDnd(!UiState.dnd)
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Theme.line
            }
        }

        Item {
            id: clearRow
            anchors.top: dndRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "CLEAR ALL"
                color: Notifs.history.length ? Theme.inkDim : Theme.line
                font.family: Theme.mono
                font.pixelSize: 8
                font.letterSpacing: 1.2
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifs.clearHistory()
            }
        }

        ListView {
            id: historyList
            anchors.top: clearRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            model: Notifs.history
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: historyRow
                required property var modelData

                width: historyList.width
                height: historyColumn.implicitHeight + 20
                color: historyMouse.containsMouse ? Theme.bg1 : "transparent"

                Column {
                    id: historyColumn
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Row {
                        spacing: 8

                        Text {
                            text: (historyRow.modelData.app || "NOTIFICATION").toUpperCase()
                            color: Theme.inkDim
                            font.family: Theme.mono
                            font.pixelSize: 8
                            font.letterSpacing: 1.1
                        }

                        Text {
                            text: {
                                var d = new Date(historyRow.modelData.when);
                                return (d.getHours() < 10 ? "0" : "") + d.getHours() + ":" + (d.getMinutes() < 10 ? "0" : "") + d.getMinutes();
                            }
                            color: Theme.inkDim
                            font.family: Theme.mono
                            font.pixelSize: 8
                        }
                    }

                    Text {
                        width: parent.width
                        text: historyRow.modelData.summary
                        color: Theme.ink
                        elide: Text.ElideRight
                        font.family: Theme.mono
                        font.pixelSize: 11
                    }

                    Text {
                        width: parent.width
                        visible: text.length > 0
                        text: historyRow.modelData.body
                        color: Theme.inkDim
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        font.family: Theme.mono
                        font.pixelSize: 9
                    }
                }

                MouseArea {
                    id: historyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Notifs.removeHistory(historyRow.modelData)
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: Theme.line
                }
            }
        }
    }
}
