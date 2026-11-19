import QtQuick
import "../core"

// Desktop-entry launcher.
Item {
    id: root

    property string query: ""
    property var results: []

    function refresh() {
        results = Launcher.search(query);
        Qt.callLater(function () {
            resultList.currentIndex = results.length > 0 ? 0 : -1;
        });
    }

    function launchCurrent() {
        if (resultList.currentIndex < 0 || resultList.currentIndex >= results.length)
            return;
        Launcher.launch(results[resultList.currentIndex]);
        UiState.close();
    }

    Component.onCompleted: {
        query = "";
        refresh();
        search.forceActiveFocus();
    }


    onVisibleChanged: {
        if (visible) {
            search.text = "";
            query = "";
            refresh();
            search.forceActiveFocus();
        }
    }

    PanelFrame {
        anchors.fill: parent
        title: "LAUNCH"
        hint: "↑ ↓ SELECT · ENTER LAUNCH · ESC CLOSE"

        Rectangle {
            id: searchBox
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            height: 38
            color: Theme.bg1
            border.width: 1
            border.color: search.activeFocus ? Theme.lineStrong : Theme.line

            TextInput {
                id: search
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.ink
                selectionColor: Theme.cream
                selectedTextColor: Theme.bg0
                font.family: Theme.mono
                font.pixelSize: 12
                clip: true

                onTextChanged: {
                    root.query = text;
                    root.refresh();
                }

                Keys.onDownPressed: {
                    if (resultList.currentIndex < resultList.count - 1)
                        resultList.currentIndex++;
                    resultList.positionViewAtIndex(resultList.currentIndex, ListView.Contain);
                }
                Keys.onUpPressed: {
                    if (resultList.currentIndex > 0)
                        resultList.currentIndex--;
                    resultList.positionViewAtIndex(resultList.currentIndex, ListView.Contain);
                }
                Keys.onReturnPressed: root.launchCurrent()
                Keys.onEnterPressed: root.launchCurrent()
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                visible: search.text.length === 0
                text: "TYPE AN APPLICATION NAME…"
                color: Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 9
                font.letterSpacing: 1.0
            }
        }

        ListView {
            id: resultList
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

                width: resultList.width
                height: 46
                color: resultList.currentIndex === index ? Theme.cream : (rowMouse.containsMouse ? Theme.bg1 : "transparent")
                readonly property bool selected: resultList.currentIndex === index

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    text: "APP"
                    color: row.selected ? Theme.bg0 : Theme.inkDim
                    font.family: Theme.mono
                    font.pixelSize: 8
                    font.letterSpacing: 1.2
                }

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 54
                    anchors.right: parent.right
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: row.modelData.name
                        color: row.selected ? Theme.bg0 : Theme.ink
                        elide: Text.ElideRight
                        width: parent.width
                        font.family: Theme.mono
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                    Text {
                        text: (row.modelData.comment || row.modelData.genericName || "").toUpperCase()
                        color: row.selected ? Theme.bg0 : Theme.inkDim
                        elide: Text.ElideRight
                        width: parent.width
                        font.family: Theme.mono
                        font.pixelSize: 8
                        font.letterSpacing: 0.8
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        resultList.currentIndex = index;
                        root.launchCurrent();
                    }
                }
            }
        }
    }
}
