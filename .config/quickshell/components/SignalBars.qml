import QtQuick
import "../core"

// Four ascending signal bars (network / wifi).
Row {
    id: root

    property int filled: 0
    property int count: 4
    property color fillColor: Theme.cream
    property color emptyColor: Theme.line

    spacing: 2

    Repeater {
        model: root.count

        delegate: Item {
            width: 3
            height: 11

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 3 + index * 2.5
                color: index < root.filled ? root.fillColor : root.emptyColor
            }
        }
    }
}
