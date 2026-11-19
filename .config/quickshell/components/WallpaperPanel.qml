import QtQuick
import Quickshell
import Quickshell.Io
import "../core"

// Wallpaper picker: thumbnails from ~/Pictures/Wallpapers.
Item {
    id: root

    property string current: ""
    property string selected: ""

    property Process currentProcess: Process {
        command: ["hyprctl", "hyprpaper", "listactive"]
        stdout: StdioCollector {
            onStreamFinished: {
                var line = String(text || "").split("\n")[0];
                var colon = line.indexOf(": ");
                root.current = colon >= 0 ? line.substring(colon + 2) : "";
            }
        }
    }

    Component.onCompleted: {
        Wallpapers.refresh();
        if (!currentProcess.running)
            currentProcess.running = true;
    }

    onVisibleChanged: {
        if (visible)
            Wallpapers.refresh();
    }

    PanelFrame {
        anchors.fill: parent
        title: "WALLPAPER"
        hint: "CLICK TO APPLY · IMAGES FROM ~/PICTURES/WALLPAPERS"
        footerRight: Wallpapers.files.length + " IMAGES"

        Flickable {
            anchors.fill: parent
            anchors.margins: 14
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: grid.implicitHeight
            interactive: contentHeight > height

            Grid {
                id: grid
                columns: 2
                spacing: 8
                width: parent.width

                Repeater {
                    model: Wallpapers.files

                    delegate: Item {
                        id: thumb
                        required property string modelData

                        width: (grid.width - 8) / 2
                        height: 210

                        readonly property string name: String(modelData).split("/").pop()
                        readonly property bool active: modelData === root.current

                        Rectangle {
                            anchors.fill: parent
                            color: Theme.bg1
                            border.width: 1
                            border.color: (thumb.active || thumbMouse.containsMouse) ? Theme.cream : Theme.line

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                source: "file://" + thumb.modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                clip: true
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            width: parent.width
                            text: thumb.name.toUpperCase()
                            color: Theme.ink
                            elide: Text.ElideRight
                            font.family: Theme.mono
                            font.pixelSize: 7
                            font.letterSpacing: 0.8
                        }

                        MouseArea {
                            id: thumbMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Wallpapers.apply(thumb.modelData);
                                UiState.close();
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: Wallpapers.files.length === 0
            text: "NO IMAGES IN ~/PICTURES/WALLPAPERS"
            color: Theme.inkDim
            font.family: Theme.mono
            font.pixelSize: 9
            font.letterSpacing: 1.2
        }
    }
}
