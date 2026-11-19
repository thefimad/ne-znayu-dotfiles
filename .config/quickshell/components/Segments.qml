import QtQuick
import "../core"

// 4-segment meter used for volume and network signal.
Row {
    id: root

    property int segmentCount: 4
    property int filled: 0
    property color fillColor: Theme.cream
    property color emptyColor: Theme.line
    property int segmentWidth: 7
    property int segmentHeight: 3

    spacing: 2

    Repeater {
        model: root.segmentCount
        Rectangle {
            width: root.segmentWidth
            height: root.segmentHeight
            color: index < root.filled ? root.fillColor : root.emptyColor
        }
    }
}
