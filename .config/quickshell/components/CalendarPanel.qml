import QtQuick
import Quickshell
import "../core"

// Clock + month calendar.
Item {
    id: root

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    readonly property var cells: {
        var d = clock.date;
        var year = d.getFullYear();
        var month = d.getMonth();
        var first = new Date(year, month, 1);
        var offset = (first.getDay() + 6) % 7;
        var days = new Date(year, month + 1, 0).getDate();
        var list = [];
        for (var i = 0; i < 42; i++) {
            var day = i - offset + 1;
            list.push(day >= 1 && day <= days ? day : 0);
        }
        return list;
    }

    readonly property string monthName: {
        var names = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"];
        return names[clock.date.getMonth()] + " " + clock.date.getFullYear();
    }

    readonly property string dateLine: {
        var days = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"];
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        var d = clock.date;
        return days[d.getDay()] + " " + d.getDate() + " " + months[d.getMonth()];
    }

    readonly property string timeText: {
        var h = clock.hours;
        var m = clock.minutes;
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
    }

    PanelFrame {
        anchors.fill: parent
        title: "CALENDAR"
        hint: "SUPER + A AUDIO · SUPER + N NOTIFICATIONS"
        footerRight: "24-HOUR · MON"

        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            spacing: 2

            Text {
                text: root.timeText
                color: Theme.cream
                font.family: Theme.mono
                font.pixelSize: 56
                font.weight: Font.ExtraBold
                font.letterSpacing: -1.5
            }

            Text {
                text: root.dateLine
                color: Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 9
                font.letterSpacing: 1.4
            }

            Item {
                width: 1
                height: 12
            }

            Text {
                text: root.monthName
                color: Theme.ink
                font.family: Theme.mono
                font.pixelSize: 12
                font.weight: Font.Bold
                font.letterSpacing: 1.6
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 16
            spacing: 4

            Row {
                spacing: 0
                Repeater {
                    model: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
                    delegate: Item {
                        required property string modelData
                        width: (root.width - 32) / 7
                        height: 20

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: Theme.inkDim
                            font.family: Theme.mono
                            font.pixelSize: 7
                            font.letterSpacing: 0.6
                        }
                    }
                }
            }

            Grid {
                columns: 7
                spacing: 0

                Repeater {
                    model: root.cells
                    delegate: Item {
                        required property int modelData
                        width: (root.width - 32) / 7
                        height: 26

                        readonly property bool today: modelData === clock.date.getDate()

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            color: parent.today ? Theme.cream : "transparent"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData > 0 ? String(modelData) : ""
                            color: modelData === 0 ? "transparent" : (parent.today ? Theme.bg0 : Theme.ink)
                            font.family: Theme.mono
                            font.pixelSize: 10
                            font.weight: parent.today ? Font.Bold : Font.Normal
                        }
                    }
                }
            }
        }
    }
}
