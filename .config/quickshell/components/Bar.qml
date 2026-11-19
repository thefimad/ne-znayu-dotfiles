import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Bluetooth
import "../core"

// 30px full-width bar: workspaces | title/media | layout, volume, net, bt, clock.
PanelWindow {
    id: bar

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 30
    color: Theme.bg0
    focusable: false

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell-bar"
    WlrLayershell.exclusiveZone: 30
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    property string layoutCode: "US"
    property int revision: 0

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Connections {
        target: Hyprland
        function onRawEvent() { bar.revision++; }
    }

    Process {
        id: devicesProcess
        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: bar.parseDevices(text)
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!devicesProcess.running)
                devicesProcess.running = true;
        }
    }

    function parseDevices(raw) {
        try {
            var data = JSON.parse(raw);
            var keyboards = data.keyboards || [];
            var keyboard = null;
            for (var i = 0; i < keyboards.length; i++) {
                if (keyboards[i].main)
                    keyboard = keyboards[i];
            }
            if (!keyboard && keyboards.length)
                keyboard = keyboards[0];
            if (!keyboard)
                return;
            var keymap = String(keyboard.active_keymap || "").toLowerCase();
            layoutCode = (keymap.indexOf("russian") !== -1 || keymap.indexOf("ru") === 0) ? "RU" : "US";
        } catch (error) {
            // keep the last known layout
        }
    }

    // ---------------- networking / bluetooth ----------------

    readonly property var netDevices: Networking.devices.values
    readonly property var wifiDevice: {
        for (var i = 0; i < netDevices.length; i++) {
            if (netDevices[i].type === DeviceType.Wifi)
                return netDevices[i];
        }
        return null;
    }
    readonly property var wiredDevice: {
        for (var i = 0; i < netDevices.length; i++) {
            if (netDevices[i].type === DeviceType.Wired)
                return netDevices[i];
        }
        return null;
    }
    readonly property var connectedWifi: {
        if (!wifiDevice)
            return null;
        var networks = wifiDevice.networks.values;
        for (var i = 0; i < networks.length; i++) {
            if (networks[i].connected)
                return networks[i];
        }
        return null;
    }
    readonly property bool wired: wiredDevice ? wiredDevice.connected : false
    readonly property string netLabel: wired ? "ETH" : "NET"
    readonly property int netBars: wired ? 4 : (connectedWifi ? Math.max(1, Math.ceil(connectedWifi.signalStrength * 4)) : 0)
    readonly property bool netUp: wired || connectedWifi !== null

    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btConnected: {
        if (!btAdapter)
            return false;
        var devices = btAdapter.devices.values;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].connected)
                return true;
        }
        return false;
    }

    // ---------------- workspaces ----------------

    readonly property int activeWorkspace: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    function workspaceOccupied(id) {
        var toplevels = Hyprland.toplevels.values;
        for (var i = 0; i < toplevels.length; i++) {
            if (toplevels[i].workspace && toplevels[i].workspace.id === id)
                return true;
        }
        return false;
    }

    function workspaceName(id) {
        return id === 10 ? "0" : String(id);
    }

    function focusWorkspace(id) {
        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", String(id)]);
    }

    // ---------------- text ----------------

    readonly property string windowTitle: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
    readonly property string mediaText: Media.active && Media.playing
        ? ("▶ " + Media.title + (Media.artist.length ? " — " + Media.artist : ""))
        : ""
    readonly property string centerText: (mediaText.length ? mediaText : windowTitle).toUpperCase()
    readonly property bool mediaActive: mediaText.length > 0

    readonly property int volumePercent: Audio.volume
    readonly property string volumeText: Audio.muted ? "MUTE" : "VOL " + Audio.volume

    readonly property string dateText: {
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        var days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var d = clock.date;
        return days[d.getDay()] + " " + (d.getDate() < 10 ? "0" : "") + d.getDate() + " " + months[d.getMonth()];
    }

    readonly property string timeText: {
        var h = clock.hours;
        var m = clock.minutes;
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
    }

    // ---------------- chrome ----------------

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.line
    }

    // LEFT: workspaces 1-5 | 6-0
    Row {
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Repeater {
            model: [1, 2, 3, 4, 5]
            delegate: workspaceCell
        }

        Item {
            width: 9
            height: 18
            Rectangle {
                anchors.centerIn: parent
                width: 1
                height: 10
                color: Theme.line
            }
        }

        Repeater {
            model: [6, 7, 8, 9, 10]
            delegate: workspaceCell
        }
    }

    Component {
        id: workspaceCell
        Item {
            id: cell
            width: 22
            height: 18

            readonly property int wsId: modelData
            readonly property bool active: bar.activeWorkspace === modelData
            readonly property bool occupied: {
                bar.revision;
                return bar.workspaceOccupied(modelData);
            }

            Rectangle {
                anchors.fill: parent
                color: cell.active ? Theme.cream : "transparent"
            }

            Text {
                anchors.centerIn: parent
                text: bar.workspaceName(cell.wsId)
                color: cell.active ? Theme.bg0 : (cell.occupied ? Theme.cream : Theme.inkDim)
                font.family: Theme.mono
                font.pixelSize: 10
                font.weight: cell.active ? Font.Bold : Font.Normal
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: bar.focusWorkspace(cell.wsId)
            }
        }
    }

    // CENTER: current title or playing media
    Item {
        anchors.centerIn: parent
        width: Math.max(200, bar.width - 900)
        height: parent.height

        Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: bar.centerText
            color: bar.mediaActive ? Theme.ink : Theme.inkDim
            elide: Text.ElideRight
            font.family: Theme.mono
            font.pixelSize: 9
            font.letterSpacing: 1.2
        }

        MouseArea {
            anchors.fill: parent
            enabled: bar.mediaActive
            cursorShape: bar.mediaActive ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                if (bar.mediaActive)
                    UiState.toggle("media");
            }
        }
    }

    // RIGHT: layout | volume | net | bt | notifications | date | time
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12

        // Layout chip
        Item {
            width: 24
            height: 30

            Text {
                anchors.centerIn: parent
                text: bar.layoutCode
                color: bar.layoutCode === "RU" ? Theme.cream : Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 1.0
            }
        }

        VSep {}

        // Volume
        Item {
            width: volumeRow.implicitWidth
            height: 30

            Row {
                id: volumeRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 7

                Text {
                    height: 14
                    verticalAlignment: Text.AlignVCenter
                    text: bar.volumeText
                    color: Audio.muted ? Theme.amber : Theme.ink
                    font.family: Theme.mono
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    font.letterSpacing: 0.6
                }

                Item {
                    width: 34
                    height: 14

                    Segments {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !Audio.muted
                        filled: Math.ceil(bar.volumePercent / 25)
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: function (mouse) {
                    if (mouse.button === Qt.RightButton)
                        Audio.toggleMute(Audio.sink);
                    else
                        UiState.toggle("audio");
                }
            }

            WheelHandler {
                onWheel: function (event) {
                    Audio.nudge(Audio.sink, event.angleDelta.y > 0 ? 5 : -5);
                }
            }
        }

        VSep {}

        // Network
        Item {
            width: netRow.implicitWidth
            height: 30

            Row {
                id: netRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    height: 14
                    verticalAlignment: Text.AlignVCenter
                    text: bar.netLabel
                    color: bar.netUp ? Theme.ink : Theme.inkDim
                    font.family: Theme.mono
                    font.pixelSize: 10
                    font.letterSpacing: 0.6
                }

                Item {
                    width: 22
                    height: 14

                    SignalBars {
                        anchors.centerIn: parent
                        filled: bar.netBars
                        fillColor: bar.netUp ? Theme.cream : Theme.line
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: UiState.toggle("system")
            }
        }

        VSep {}

        // Bluetooth
        Item {
            width: 20
            height: 30

            Text {
                anchors.centerIn: parent
                text: "BT"
                color: bar.btConnected ? Theme.cream : Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 0.8
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: UiState.toggle("system")
            }
        }

        VSep {}

        // Notification history
        Item {
            width: 16
            height: 30

            Text {
                anchors.centerIn: parent
                text: "N"
                color: UiState.unseen > 0 ? Theme.cream : Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: 8
                width: 4
                height: 4
                color: Theme.amber
                visible: UiState.unseen > 0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: UiState.toggle("notifications")
            }
        }

        VSep {}

        // Date
        Item {
            width: dateLabel.implicitWidth
            height: 30

            Text {
                id: dateLabel
                anchors.centerIn: parent
                text: bar.dateText
                color: Theme.inkDim
                font.family: Theme.mono
                font.pixelSize: 9
                font.letterSpacing: 1.0
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: UiState.toggle("calendar")
            }
        }

        VSep {}

        // Clock
        Item {
            width: clockLabel.implicitWidth
            height: 30

            Text {
                id: clockLabel
                anchors.centerIn: parent
                text: bar.timeText
                color: Theme.ink
                font.family: Theme.mono
                font.pixelSize: 13
                font.weight: Font.Bold
                font.letterSpacing: 0.6
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: UiState.toggle("calendar")
            }
        }
    }
}
