import QtQuick
import "../core"

// Searchable clipboard history (cliphist + wl-clipboard).
Item {
    id: root

    property string query: ""
    property var results: []

    function refresh() {
        var needle = query.toLowerCase().trim();
        var result = [];
        for (var i = 0; i < Clipboard.entries.length; i++) {
            var entry = Clipboard.entries[i];
            if (needle.length === 0 || entry.preview.toLowerCase().indexOf(needle) !== -1)
                result.push(entry);
        }
        results = result;
        Qt.callLater(function () {
            clipList.currentIndex = result.length > 0 ? 0 : -1;
        });
    }

    function copyCurrent() {
        if (clipList.currentIndex < 0 || clipList.currentIndex >= results.length)
            return;
        Clipboard.copy(results[clipList.currentIndex]);
        UiState.close();
    }

    function removeCurrent() {
        if (clipList.currentIndex < 0 || clipList.currentIndex >= results.length)
            return;
        Clipboard.remove(results[clipList.currentIndex]);
        Qt.callLater(refresh);
    }

    function typeLabel(entry) {
        return entry.preview.indexOf("[[ binary data") === 0 ? "IMAGE" : "TEXT";
    }

    function previewText(entry) {
        var first = String(entry.preview).split("\n")[0];
        if (entry.preview.indexOf("[[ binary data") !== 0)
            return first;
        var match = first.match(/binary data\s+(.+?)\s+(\d+x\d+)\s*\]\]/);
        if (match)
            return match[2].replace("x", "×") + " · " + match[1];
        return "IMAGE";
    }

    Component.onCompleted: {
        Clipboard.reload();
        refresh();
        search.forceActiveFocus();
    }

    onVisibleChanged: {
        if (visible) {
            Clipboard.reload();
            refresh();
            search.forceActiveFocus();
        }
    }

    Connections {
        target: Clipboard
        function onEntriesChanged() { root.refresh(); }
    }

    PanelFrame {
        anchors.fill: parent
        title: "CLIPBOARD"
        hint: "ENTER COPY · DELETE REMOVE · CTRL+DELETE CLEAR"
        footerRight: Clipboard.entries.length + " ENTRIES"

        Rectangle {
            id: searchBox
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            height: 34
            color: Theme.bg1
            border.width: 1
            border.color: search.activeFocus ? Theme.lineStrong : Theme.line

            TextInput {
                id: search
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.ink
                selectionColor: Theme.cream
                selectedTextColor: Theme.bg0
                font.family: Theme.mono
                font.pixelSize: 11
                clip: true

                onTextChanged: {
                    root.query = text;
                    root.refresh();
                }

                Keys.onDownPressed: {
                    if (clipList.currentIndex < clipList.count - 1)
                        clipList.currentIndex++;
                    clipList.positionViewAtIndex(clipList.currentIndex, ListView.Contain);
                }
                Keys.onUpPressed: {
                    if (clipList.currentIndex > 0)
                        clipList.currentIndex--;
                    clipList.positionViewAtIndex(clipList.currentIndex, ListView.Contain);
                }
                Keys.onReturnPressed: root.copyCurrent()
                Keys.onEnterPressed: root.copyCurrent()

                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Delete) {
                        if (event.modifiers & Qt.ControlModifier) {
                            Clipboard.wipe();
                            event.accepted = true;
                        } else if (text.length === 0) {
                            root.removeCurrent();
                            event.accepted = true;
                        }
                    }
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: search.text.length === 0
                text: "FILTER HISTORY…"
                color: Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 9
                font.letterSpacing: 1.0
            }
        }

        ListView {
            id: clipList
            anchors.top: searchBox.bottom
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            model: root.results
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: row
                required property var modelData
                required property int index

                width: clipList.width
                height: 40
                color: clipList.currentIndex === index ? Theme.cream : (rowMouse.containsMouse ? Theme.bg1 : "transparent")
                readonly property bool selected: clipList.currentIndex === index

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.right: typeText.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: root.previewText(row.modelData)
                        color: row.selected ? Theme.bg0 : Theme.ink
                        elide: Text.ElideRight
                        width: parent.width
                        font.family: Theme.mono
                        font.pixelSize: 11
                    }

                    Text {
                        text: root.typeLabel(row.modelData)
                        color: row.selected ? Theme.bg0 : Theme.inkDim
                        font.family: Theme.mono
                        font.pixelSize: 8
                        font.letterSpacing: 1.2
                    }
                }

                Text {
                    id: typeText
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: "#" + row.modelData.id
                    color: row.selected ? Theme.bg0 : Theme.inkDim
                    font.family: Theme.mono
                    font.pixelSize: 8
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        clipList.currentIndex = index;
                        root.copyCurrent();
                    }
                }
            }
        }
    }
}
