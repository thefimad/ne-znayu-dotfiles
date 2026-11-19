import QtQuick
import Quickshell.Networking
import Quickshell.Bluetooth
import "../core"

// SYSTEM: Wi-Fi + Bluetooth.
Item {
    id: root

    property var passwordTarget: null
    property string password: ""

    readonly property var wifiDevice: {
        var devices = Networking.devices.values;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].type === DeviceType.Wifi)
                return devices[i];
        }
        return null;
    }

    readonly property var wifiNetworks: wifiDevice ? wifiDevice.networks.values : []

    readonly property var sortedWifi: {
        var list = [];
        for (var i = 0; i < wifiNetworks.length; i++)
            list.push(wifiNetworks[i]);
        list.sort(function (a, b) {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.known !== b.known)
                return a.known ? -1 : 1;
            return (b.signalStrength || 0) - (a.signalStrength || 0);
        });
        return list;
    }

    readonly property var btAdapter: Bluetooth.defaultAdapter

    readonly property var btDevices: {
        if (!btAdapter)
            return [];
        var source = btAdapter.devices.values;
        var list = [];
        for (var i = 0; i < source.length; i++) {
            if (source[i].paired || source[i].connected || btAdapter.discovering)
                list.push(source[i]);
        }
        list.sort(function (a, b) {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;
            return String(a.name).localeCompare(String(b.name));
        });
        return list;
    }

    function wifiBars(network) {
        return Math.max(1, Math.ceil((network.signalStrength || 0) * 4));
    }

    function wifiClick(network) {
        if (network.connected) {
            network.disconnect();
        } else if (network.known) {
            network.connect();
        } else if (network.security !== WifiSecurityType.Open) {
            passwordTarget = network;
            password = "";
        } else {
            network.connect();
        }
    }

    function connectWithPassword() {
        if (!passwordTarget)
            return;
        passwordTarget.connectWithPsk(password);
        passwordTarget = null;
        password = "";
    }

    function btClick(device) {
        if (device.connected)
            device.disconnect();
        else if (device.paired)
            device.connect();
        else
            device.pair();
    }

    Component.onCompleted: {
        if (wifiDevice)
            wifiDevice.scannerEnabled = true;
    }

    onVisibleChanged: {
        if (wifiDevice)
            wifiDevice.scannerEnabled = visible;
    }

    PanelFrame {
        anchors.fill: parent
        title: "SYSTEM"
        hint: "CLICK A NETWORK OR DEVICE · ESC CLOSE"
        footerRight: "NETWORKMANAGER · BLUEZ"

        Flickable {
            anchors.fill: parent
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentHeight: column.implicitHeight
            interactive: contentHeight > height

            Column {
                id: column
                width: parent.width

                SectionLabel { label: "WIFI" }

                Item {
                    width: parent.width
                    height: 34

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: "WIFI"
                        color: Networking.wifiEnabled ? Theme.ink : Theme.inkDim
                        font.family: Theme.mono
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.0
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: Networking.wifiEnabled ? "ON" : "OFF"
                        color: Networking.wifiEnabled ? Theme.cream : Theme.inkDim
                        font.family: Theme.mono
                        font.pixelSize: 8
                        font.letterSpacing: 1.2
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                    }
                }

                // Inline password field for a new secured network.
                Rectangle {
                    width: parent.width
                    height: root.passwordTarget ? 44 : 0
                    visible: root.passwordTarget !== null
                    color: Theme.bg1

                    TextInput {
                        id: passwordField
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.right: connectLabel.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.password
                        color: Theme.ink
                        echoMode: TextInput.Password
                        selectionColor: Theme.cream
                        selectedTextColor: Theme.bg0
                        font.family: Theme.mono
                        font.pixelSize: 11
                        focus: root.passwordTarget !== null
                        clip: true
                        onTextChanged: root.password = text
                        onAccepted: root.connectWithPassword()

                        Keys.onEscapePressed: {
                            root.passwordTarget = null;
                            root.password = "";
                        }
                    }

                    Text {
                        id: connectLabel
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: "CONNECT"
                        color: Theme.cream
                        font.family: Theme.mono
                        font.pixelSize: 8
                        font.letterSpacing: 1.2

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.connectWithPassword()
                        }
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        visible: passwordField.text.length === 0
                        text: "PASSWORD FOR " + (root.passwordTarget ? root.passwordTarget.name.toUpperCase() : "")
                        color: Theme.inkDim
                        font.family: Theme.mono
                        font.pixelSize: 8
                        font.letterSpacing: 0.8
                    }
                }

                Repeater {
                    model: root.sortedWifi
                    delegate: Item {
                        id: wifiRow
                        required property var modelData

                        width: column.width
                        height: 42

                        Rectangle {
                            anchors.fill: parent
                            color: wifiMouse.containsMouse ? Theme.bg1 : "transparent"
                        }

                        Item {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            width: 30
                            height: 12

                            SignalBars {
                                anchors.verticalCenter: parent.verticalCenter
                                filled: root.wifiBars(wifiRow.modelData)
                                fillColor: wifiRow.modelData.connected ? Theme.cream : Theme.inkDim
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 54
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: stateLabel.left
                            anchors.rightMargin: 8
                            text: wifiRow.modelData.name
                            color: Theme.ink
                            elide: Text.ElideRight
                            font.family: Theme.mono
                            font.pixelSize: 11
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 54
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 6
                            visible: wifiRow.modelData.security !== WifiSecurityType.Open
                            text: "LOCK"
                            color: Theme.inkDim
                            font.family: Theme.mono
                            font.pixelSize: 7
                            font.letterSpacing: 1.0
                        }

                        Text {
                            id: stateLabel
                            anchors.right: parent.right
                            anchors.rightMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: wifiRow.modelData.connected ? "LIVE" : (wifiRow.modelData.known ? "SAVED" : "NEW")
                            color: wifiRow.modelData.connected ? Theme.cream : Theme.inkDim
                            font.family: Theme.mono
                            font.pixelSize: 8
                            font.letterSpacing: 1.2
                        }

                        MouseArea {
                            id: wifiMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.wifiClick(wifiRow.modelData)
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 8
                }

                SectionLabel { label: "BLUETOOTH" }

                Item {
                    width: parent.width
                    height: 34

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: "BT"
                        color: root.btAdapter && root.btAdapter.enabled ? Theme.ink : Theme.inkDim
                        font.family: Theme.mono
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1.0
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.btAdapter && root.btAdapter.enabled ? "ON" : "OFF"
                        color: root.btAdapter && root.btAdapter.enabled ? Theme.cream : Theme.inkDim
                        font.family: Theme.mono
                        font.pixelSize: 8
                        font.letterSpacing: 1.2
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.btAdapter)
                                root.btAdapter.enabled = !root.btAdapter.enabled;
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 30
                    visible: root.btAdapter && root.btAdapter.enabled

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.btAdapter && root.btAdapter.discovering ? "SCANNING" : "SCAN"
                        color: root.btAdapter && root.btAdapter.discovering ? Theme.amber : Theme.inkDim
                        font.family: Theme.mono
                        font.pixelSize: 8
                        font.letterSpacing: 1.2
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.btAdapter)
                                root.btAdapter.discovering = !root.btAdapter.discovering;
                        }
                    }
                }

                Repeater {
                    model: root.btDevices
                    delegate: Item {
                        id: btRow
                        required property var modelData

                        width: column.width
                        height: 40

                        Rectangle {
                            anchors.fill: parent
                            color: btMouse.containsMouse ? Theme.bg1 : "transparent"
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.right: btState.left
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: (btRow.modelData.name || btRow.modelData.deviceName || btRow.modelData.address).toUpperCase()
                            color: Theme.ink
                            elide: Text.ElideRight
                            font.family: Theme.mono
                            font.pixelSize: 10
                        }

                        Text {
                            id: btState
                            anchors.right: parent.right
                            anchors.rightMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: btRow.modelData.connected ? "LIVE" : (btRow.modelData.paired ? "PAIRED" : "NEW")
                            color: btRow.modelData.connected ? Theme.cream : Theme.inkDim
                            font.family: Theme.mono
                            font.pixelSize: 8
                            font.letterSpacing: 1.2
                        }

                        MouseArea {
                            id: btMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.btClick(btRow.modelData)
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 14
                }
            }
        }
    }
}
