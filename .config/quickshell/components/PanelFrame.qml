import QtQuick
import "../core"

// Shared opaque panel frame: header + hairline + body + footer hint.
Rectangle {
    id: root

    property string title: ""
    property string hint: "ESC CLOSE"
    property string footerRight: ""
    default property alias content: body.data

    implicitWidth: 400
    implicitHeight: 520
    color: Theme.bg0
    border.width: 1
    border.color: Theme.line
    radius: 0

    // Swallow clicks so the full-screen scrim underneath doesn't close the panel.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
    }

    Rectangle {
        id: header
        width: parent.width
        height: 38
        color: "transparent"

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: root.title.toUpperCase()
            color: Theme.ink
            font.family: Theme.mono
            font.pixelSize: 12
            font.weight: Font.Bold
            font.letterSpacing: 1.6
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: "ESC"
            color: Theme.inkDim
            font.family: Theme.mono
            font.pixelSize: 9
            font.letterSpacing: 1.1

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: UiState.close()
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Theme.line
        }
    }

    Item {
        id: body
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
    }

    Rectangle {
        id: footer
        anchors.bottom: parent.bottom
        width: parent.width
        height: 28
        color: "transparent"

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: Theme.line
        }

        Text {
            id: footerHintText
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(0, footer.width - footerRightText.width - 42)
            elide: Text.ElideRight
            text: root.hint.toUpperCase()
            color: Theme.inkDim
            font.family: Theme.mono
            font.pixelSize: 8
            font.letterSpacing: 1.2
        }

        Text {
            id: footerRightText
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: root.footerRight.toUpperCase()
            color: Theme.inkDim
            font.family: Theme.mono
            font.pixelSize: 8
            font.letterSpacing: 1.2
        }
    }
}
