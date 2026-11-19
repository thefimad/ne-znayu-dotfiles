import QtQuick
import "../core"

// Full mixer: outputs, inputs, per-app streams.
Item {
    id: root

    PanelFrame {
        anchors.fill: parent
        title: "AUDIO"
        hint: "CLICK = DEFAULT · SCROLL = VOL"
        footerRight: "DEFAULT: " + Audio.label(Audio.sink)

        Flickable {
            anchors.fill: parent
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: column.implicitHeight
            interactive: contentHeight > height

            Column {
                id: column
                width: parent.width

                SectionLabel { label: "OUTPUT" }

                Repeater {
                    model: Audio.sinks
                    delegate: DeviceRow {
                        node: modelData
                        selected: modelData === Audio.sink
                        isSource: false
                        canDefault: true
                    }
                }

                SectionLabel { label: "INPUT" }

                Repeater {
                    model: Audio.sources
                    delegate: DeviceRow {
                        node: modelData
                        selected: modelData === Audio.source
                        isSource: true
                        canDefault: true
                    }
                }

                SectionLabel { label: "STREAMS" }

                Repeater {
                    model: Audio.streams
                    delegate: DeviceRow {
                        node: modelData
                        selected: false
                        isSource: false
                        canDefault: false
                    }
                }

                Item {
                    width: parent.width
                    height: Audio.streams.length === 0 ? 40 : 0

                    Text {
                        anchors.centerIn: parent
                        text: "NO ACTIVE STREAMS"
                        color: Theme.inkDim
                        font.family: Theme.mono
                        font.pixelSize: 9
                        font.letterSpacing: 1.2
                    }
                }

                Item {
                    width: parent.width
                    height: 10
                }
            }
        }
    }
}
