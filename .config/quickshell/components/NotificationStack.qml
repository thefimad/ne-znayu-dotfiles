import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core"

// Top-right notification popup stack (360 wide).
PanelWindow {
    id: root

    anchors.top: true
    anchors.right: true
    margins.top: 38
    margins.right: 12
    implicitWidth: 360
    implicitHeight: column.implicitHeight
    color: "transparent"
    focusable: false
    visible: Notifs.popups.length > 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Column {
        id: column
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.popups

            delegate: Rectangle {
                id: card
                required property var modelData

                width: column.width
                height: cardColumn.implicitHeight + 22
                color: Theme.bg0
                border.width: 1
                border.color: Theme.line

                readonly property bool critical: modelData.urgency === 3

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 2
                    color: Theme.amber
                    visible: card.critical
                }

                Column {
                    id: cardColumn
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    spacing: 3

                    Text {
                        width: parent.width
                        text: (card.modelData.app || "NOTIFICATION").toUpperCase()
                        color: Theme.inkDim
                        elide: Text.ElideRight
                        font.family: Theme.mono
                        font.pixelSize: 9
                        font.letterSpacing: 1.2
                    }

                    Text {
                        width: parent.width
                        text: card.modelData.summary
                        color: Theme.ink
                        elide: Text.ElideRight
                        font.family: Theme.mono
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        width: parent.width
                        visible: text.length > 0
                        text: card.modelData.body
                        color: Theme.inkDim
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        font.family: Theme.mono
                        font.pixelSize: 12
                    }

                    Row {
                        visible: card.modelData.raw && card.modelData.raw.actions && card.modelData.raw.actions.length > 0

                        Repeater {
                            model: card.modelData.raw && card.modelData.raw.actions ? card.modelData.raw.actions : []

                            delegate: Item {
                                required property var modelData
                                width: actionText.implicitWidth + 16
                                height: 18

                                Text {
                                    id: actionText
                                    anchors.centerIn: parent
                                    text: modelData.text.toUpperCase()
                                    color: Theme.cream
                                    font.family: Theme.mono
                                    font.pixelSize: 8
                                    font.letterSpacing: 1.0
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        modelData.invoke();
                                        Notifs.dismiss(card.modelData);
                                    }
                                }
                            }
                        }
                    }
                }

                // Timeout hairline.
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: card.critical ? Theme.amber : Theme.lineStrong

                    NumberAnimation on width {
                        from: card.width
                        to: 0
                        duration: card.modelData.timeout
                        running: true
                        easing.type: Easing.Linear
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: -1
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.dismiss(card.modelData)
                }
            }
        }
    }
}
