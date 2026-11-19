import QtQuick
import "../core"

// 14px vertical hairline used between bar groups (30px wrapper for Row layout).
Item {
    width: 1
    height: 30

    Rectangle {
        anchors.centerIn: parent
        width: 1
        height: 14
        color: Theme.line
    }
}
