import QtQuick
import "../core"

// Searchable keybind cheatsheet, generated from modules/keybinds.lua.
Item {
    id: root

    property string query: ""
    property var filtered: []

    function refresh() {
        var needle = query.toLowerCase().trim();
        var result = [];
        for (var i = 0; i < Keybinds.binds.length; i++) {
            var bind = Keybinds.binds[i];
            var haystack = (bind.key + " " + bind.category + " " + bind.description).toLowerCase();
            if (needle.length === 0 || haystack.indexOf(needle) !== -1)
                result.push(bind);
        }
        filtered = result;
        Qt.callLater(function () {
            bindList.currentIndex = result.length > 0 ? 0 : -1;
        });
    }

    function generatedLabel() {
        if (!Keybinds.generated)
            return "";
        var d = new Date(Keybinds.generated * 1000);
        var h = d.getHours();
        var m = d.getMinutes();
        return "GENERATED " + (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m + " · " + Keybinds.count + " BINDS";
    }

    Component.onCompleted: {
        refresh();
        search.forceActiveFocus();
    }

    onVisibleChanged: {
        if (visible) {
            refresh();
            search.forceActiveFocus();
        }
    }

    Connections {
        target: Keybinds
        function onBindsChanged() { root.refresh(); }
    }

    PanelFrame {
        anchors.fill: parent
        title: "KEYBINDS"
        hint: "TYPE TO FILTER · ↑ ↓ SELECT · ESC CLOSE"
        footerRight: root.generatedLabel()

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
                    if (bindList.currentIndex < bindList.count - 1)
                        bindList.currentIndex++;
                    bindList.positionViewAtIndex(bindList.currentIndex, ListView.Contain);
                }
                Keys.onUpPressed: {
                    if (bindList.currentIndex > 0)
                        bindList.currentIndex--;
                    bindList.positionViewAtIndex(bindList.currentIndex, ListView.Contain);
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: search.text.length === 0
                text: "FILTER KEY, CATEGORY OR ACTION…"
                color: Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 9
                font.letterSpacing: 1.0
            }
        }

        ListView {
            id: bindList
            anchors.top: searchBox.bottom
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            model: root.filtered
            currentIndex: -1
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: row
                required property var modelData
                required property int index

                width: bindList.width
                height: 38
                color: bindList.currentIndex === index ? Theme.cream : (rowMouse.containsMouse ? Theme.bg1 : "transparent")
                readonly property bool selected: bindList.currentIndex === index

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Repeater {
                        model: String(row.modelData.key).split(" + ")
                        delegate: Keycap {
                            required property string modelData
                            label: modelData
                            inverted: row.selected
                        }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 230
                    anchors.right: categoryText.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.description
                    color: row.selected ? Theme.bg0 : Theme.ink
                    elide: Text.ElideRight
                    font.family: Theme.mono
                    font.pixelSize: 11
                }

                Text {
                    id: categoryText
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.category
                    color: row.selected ? Theme.bg0 : Theme.inkDim
                    font.family: Theme.mono
                    font.pixelSize: 8
                    font.letterSpacing: 1.2
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: bindList.currentIndex = index
                }
            }
        }
    }
}
